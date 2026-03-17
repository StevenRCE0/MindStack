//
//  MindStackApp.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/17.
//

import SwiftUI
import SwiftData

@main
struct MindStackApp: App {
    @State private var preferences = AppPreferences()
    @State private var donationStore = DonationStore()

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
        }
        .modelContainer(sharedModelContainer)
        .windowResizability(.contentSize)

        WindowGroup("Welcome", id: "welcome") {
            WelcomeView()
                .environment(preferences)
                .environment(donationStore)
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(preferences)
                .environment(donationStore)
        }
        .windowResizability(.contentSize)
    }
}
