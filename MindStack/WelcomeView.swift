import SwiftUI

struct WelcomeView: View {
    @Environment(AppPreferences.self) private var preferences
    @Environment(MenuBarController.self) private var menuBarController
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Welcome to MindStack")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 14) {
                feature(
                    "Reveal Anywhere",
                    detail:
                        "Bring up the floating panel from anywhere on your Mac."
                )
                feature(
                    "Build A Stack",
                    detail:
                        "Each card can grow into a short stack of connected thoughts."
                )
                feature(
                    "Force Touch to Reveal",
                    detail:
                        "Push down on the trackpad and reveal the stack."
                )
                VStack(alignment: .leading, spacing: 4) {
                    Text(
                        "MindStack starts with \(preferences.shortcut.displayText)"
                    )
                    .font(.headline)
                    Text(
                        "You can change the global reveal shortcut any time in Settings."
                    )
                    .foregroundStyle(.secondary)
                }
            }


            Spacer()

            HStack {
                Button("Customize Shortcut") {
                    openSettings()
                }
                Spacer()
                Button("Start Using MindStack") {
                    preferences.hasSeenOnboarding = true
                    NSApp.keyWindow?.close()
                    menuBarController.showMainPanel()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(32)
        .frame(width: 500)
    }

    private func feature(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(detail)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AppPreferences())
}
