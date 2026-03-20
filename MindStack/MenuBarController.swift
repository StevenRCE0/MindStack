import AppKit
import Observation

extension Notification.Name {
    static let showMindStackMainPanel = Notification.Name("showMindStackMainPanel")
}

@MainActor
@Observable
final class MenuBarController: NSObject {
    private var statusItem: NSStatusItem?

    func setMenuBarItemHidden(_ isHidden: Bool) {
        if isHidden {
            removeStatusItem()
        } else {
            installStatusItemIfNeeded()
        }
    }

    func showMainPanel() {
        NotificationCenter.default.post(name: .showMindStackMainPanel, object: nil)
    }

    private func installStatusItemIfNeeded() {
        guard statusItem == nil else { return }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(
            systemSymbolName: "rectangle.stack",
            accessibilityDescription: "Show MindStack"
        )
        item.button?.toolTip = "Show MindStack"
        item.button?.target = self
        item.button?.action = #selector(handleStatusItemPress)
        statusItem = item
    }

    private func removeStatusItem() {
        guard let statusItem else { return }
        NSStatusBar.system.removeStatusItem(statusItem)
        self.statusItem = nil
    }

    @objc
    private func handleStatusItemPress() {
        showMainPanel()
    }
}
