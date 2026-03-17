import AppKit
import HotKey

struct AppShortcut: Equatable {
    var keyCode: Int
    var modifiers: Int

    static let defaultValue = AppShortcut(
        keyCode: Int(Key.z.carbonKeyCode),
        modifiers: Int(NSEvent.ModifierFlags([.shift, .control]).carbonFlags)
    )

    init(keyCode: Int, modifiers: Int) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    init(keyCombo: KeyCombo) {
        self.init(
            keyCode: Int(keyCombo.carbonKeyCode),
            modifiers: Int(keyCombo.carbonModifiers)
        )
    }

    var keyCombo: KeyCombo {
        KeyCombo(
            carbonKeyCode: UInt32(keyCode),
            carbonModifiers: UInt32(modifiers)
        )
    }

    var displayText: String {
        keyCombo.description
    }
}
