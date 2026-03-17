import Defaults
import Observation

@MainActor
@Observable
final class AppPreferences {
    var pinnedPanel: Bool {
        didSet { Defaults[.pinnedPanel] = pinnedPanel }
    }

    var hasSeenOnboarding: Bool {
        didSet { Defaults[.hasSeenOnboarding] = hasSeenOnboarding }
    }

    var shortcut: AppShortcut {
        didSet {
            Defaults[.shortcutKeyCode] = shortcut.keyCode
            Defaults[.shortcutModifiers] = shortcut.modifiers
        }
    }

    var hideSignatureLine: Bool {
        didSet { Defaults[.hideSignatureLine] = hideSignatureLine }
    }

    var signatureText: String {
        didSet { Defaults[.signatureText] = signatureText }
    }

    init() {
        pinnedPanel = Defaults[.pinnedPanel]
        hasSeenOnboarding = Defaults[.hasSeenOnboarding]
        shortcut = AppShortcut(
            keyCode: Defaults[.shortcutKeyCode],
            modifiers: Defaults[.shortcutModifiers]
        )
        hideSignatureLine = Defaults[.hideSignatureLine]
        signatureText = Defaults[.signatureText]
    }
}
