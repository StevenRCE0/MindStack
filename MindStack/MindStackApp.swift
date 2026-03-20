//
//  MindStackApp.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/17.
//

import AppKit
import Observation
import SwiftData
import SwiftUI

@main
struct MindStackApp: App {
    @State private var preferences = AppPreferences()
    @State private var donationStore = DonationStore()
    @State private var menuBarController = MenuBarController()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            ItemGroup.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        Window("Main", id: "main") {
            ContentView()
                .environment(preferences)
                .environment(donationStore)
                .environment(menuBarController)
        }
        .modelContainer(sharedModelContainer)
        .windowResizability(.contentSize)

        WindowGroup("Welcome", id: "welcome") {
            WelcomeView()
                .environment(preferences)
                .environment(donationStore)
                .environment(menuBarController)
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(preferences)
                .environment(donationStore)
                .environment(menuBarController)
        }
        .windowResizability(.contentSize)
    }
}

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
