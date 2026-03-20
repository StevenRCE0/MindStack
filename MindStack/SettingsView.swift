import SwiftUI

struct SettingsView: View {
    @Environment(AppPreferences.self) private var preferences
    @Environment(DonationStore.self) private var donationStore
    @Environment(MenuBarController.self) private var menuBarController
    @Environment(\.openWindow) private var openWindow

    private var showsSignatureLine: Binding<Bool> {
        Binding(
            get: { !preferences.hideSignatureLine },
            set: { preferences.hideSignatureLine = !$0 }
        )
    }

    var body: some View {
        @Bindable var preferences = preferences

        Form {
            Section("Reveal Shortcut") {
                ShortcutRecorderView(shortcut: $preferences.shortcut)
            }

            Section("Intro") {
                Text(
                    "Open the welcome screen again if you want a quick refresher."
                )
                .foregroundStyle(.secondary)

                Button("Show Intro Again") {
                    preferences.hasSeenOnboarding = false
                    openWindow(id: "welcome")
                }
            }

            Section("App") {
                Toggle("Hide menu bar item", isOn: $preferences.hideMenuBarItem)

                HStack {
                    Button("Show Main Panel") {
                        menuBarController.showMainPanel()
                    }

                    Spacer()

                    Button("Quit MindStack") {
                        NSApp.terminate(nil)
                    }
                }
            }

            Section(donationStore.hasDonated ? "Signature" : "Support Link") {
                Toggle(
                    donationStore.hasDonated
                        ? "Show signature line at the bottom of the list"
                        : "Show support link at the bottom of the list",
                    isOn: showsSignatureLine
                )

                if donationStore.hasDonated {
                    TextField(
                        "Signature",
                        text: $preferences.signatureText,
                        axis: .vertical
                    )
                } else {
                    Text(
                        "Donate once to replace the support link with an editable signature."
                    )
                    .foregroundStyle(.secondary)

                    HStack {
                        Button(donationStore.donationButtonTitle) {
                            Task {
                                await donationStore.purchase()
                            }
                        }
                        .disabled(
                            donationStore.isLoading
                                || donationStore.product == nil
                        )

                        Button("Restore Purchases") {
                            Task {
                                await donationStore.restore()
                            }
                        }
                        .disabled(donationStore.isLoading)
                    }
                }

                if let errorMessage = donationStore.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 480)
        .task {
            await donationStore.refresh()
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppPreferences())
        .environment(DonationStore())
}
