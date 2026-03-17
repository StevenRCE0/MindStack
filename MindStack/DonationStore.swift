import Observation
import StoreKit

@MainActor
@Observable
final class DonationStore {
    private enum Constants {
        static let signatureProductID = "org.rcex.MindStack.signature"
    }

    private(set) var product: Product?
    private(set) var hasDonated = false
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task {
            for await update in Transaction.updates {
                guard case .verified(let transaction) = update else { continue }
                if transaction.productID == Constants.signatureProductID {
                    await transaction.finish()
                    await refreshEntitlements()
                }
            }
        }

        Task {
            await refresh()
        }
    }

    var donationButtonTitle: String {
        guard let product else { return "Donate" }
        return "Donate \(product.displayPrice)"
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            product = try await Product.products(for: [Constants.signatureProductID]).first
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func purchase() async {
        if product == nil {
            await refresh()
        }

        guard let product else {
            errorMessage = "The donation product is not available yet."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(.verified(let transaction)):
                hasDonated = true
                await transaction.finish()
            case .success(.unverified(_, let error)):
                errorMessage = error.localizedDescription
            case .pending:
                errorMessage = "The donation is still pending approval."
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func restore() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func refreshEntitlements() async {
        hasDonated = false

        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else { continue }
            guard transaction.productID == Constants.signatureProductID else { continue }

            hasDonated = true
            break
        }
    }
}
