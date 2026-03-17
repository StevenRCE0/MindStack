import Carbon
import HotKey
import SwiftUI

struct ShortcutRecorderView: View {
    @Binding var shortcut: AppShortcut

    @State private var isRecording = false
    @State private var eventMonitor: Any?
    @State private var message = "Press Record, then type the shortcut you want to use."

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(isRecording ? "Type Shortcut…" : shortcut.displayText) {
                    isRecording ? stopRecording() : startRecording()
                }

                Button("Reset") {
                    shortcut = .defaultValue
                    message = "Reverted to the default reveal shortcut."
                }
                Spacer()
            }

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onDisappear(perform: stopRecording)
    }

    private func startRecording() {
        stopRecording()
        isRecording = true
        message = "Press a key combination with at least one modifier."
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: handleEvent(_:))
    }

    private func stopRecording() {
        isRecording = false

        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }

    private func handleEvent(_ event: NSEvent) -> NSEvent? {
        let modifiers = event.modifierFlags.intersection([.command, .control, .option, .shift])

        if event.keyCode == UInt16(kVK_Escape), modifiers.isEmpty {
            message = "Shortcut capture cancelled."
            stopRecording()
            return nil
        }

        guard let key = Key(carbonKeyCode: UInt32(event.keyCode)) else {
            return nil
        }

        guard !Self.modifierKeys.contains(key) else {
            return nil
        }

        guard !modifiers.isEmpty else {
            message = "Include at least one modifier key."
            return nil
        }

        let combo = KeyCombo(key: key, modifiers: modifiers)

        guard !Self.reservedCombos.contains(combo) else {
            message = "That shortcut is already reserved by macOS."
            return nil
        }

        shortcut = AppShortcut(keyCombo: combo)
        message = "MindStack will now reveal with \(shortcut.displayText)."
        stopRecording()
        return nil
    }

    private static let modifierKeys: [Key] = [
        .command,
        .rightCommand,
        .option,
        .rightOption,
        .control,
        .rightControl,
        .shift,
        .rightShift,
        .function,
        .capsLock
    ]

    private static let reservedCombos = KeyCombo.systemKeyCombos() + KeyCombo.standardKeyCombos()
}

#Preview {
    ShortcutRecorderView(
        shortcut: .constant(.defaultValue)
    )
}
