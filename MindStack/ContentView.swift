//
//  ContentView.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/17.
//

import HotKey
import SwiftData
import SwiftUI

struct MainPanel: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppPreferences.self) private var preferences
    @Environment(DonationStore.self) private var donationStore
    @Environment(\.openSettings) private var openSettings
    @Query(
        filter: #Predicate { $0.pinned },
        sort: \ItemGroup.timestamp,
        order: .reverse
    ) private var pinnedGroups: [ItemGroup]
    @Query(
        filter: #Predicate { !$0.pinned },
        sort: \ItemGroup.timestamp,
        order: .reverse
    ) private var groups: [ItemGroup]
    @State private var addingGroup = false
    @State private var addingItem: ItemGroup? = nil

    private let overlayTopInset: CGFloat = 12
    private let overlaySideInset: CGFloat = 14
    private let contentTopInset: CGFloat = 52
    private let controlHorizontalPadding: CGFloat = 11
    private let controlVerticalPadding: CGFloat = 9

    private var allGroups: [ItemGroup] {
        pinnedGroups + groups
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                if allGroups.isEmpty {
                    VStack {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 64))
                        Text(
                            "No Stacks. Click \(Image(systemName: "plus")) to Begin"
                        )
                        .font(.title2)
                        .padding(.top)
                        .onTapGesture {
                            addingGroup.toggle()
                        }

                        signatureFooter(paddingTop: 42)
                    }
                    .foregroundStyle(.primary.opacity(0.7))
                    .blendMode(.hardLight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, contentTopInset)

                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(allGroups, id: \.id) { group in
                                MindStack(group: group)
                            }
                            signatureFooter(paddingTop: 40)
                        }
                        .padding(
                            EdgeInsets(
                                top: contentTopInset,
                                leading: 30,
                                bottom: 40,
                                trailing: 30
                            )
                        )
                    }
                }
            }

            panelControls
        }
        .animation(.snappy, value: allGroups)
    }

    private func addGroup(_ text: String) -> ItemGroup {
        let newGroup = ItemGroup(
            timestamp: Date(),
            items: [.init(timestamp: Date(), text: text)]
        )
        withAnimation {
            modelContext.insert(newGroup)
        }
        try! modelContext.save()
        return newGroup
    }

    private var panelControls: some View {
        HStack(alignment: .top) {
            HStack(spacing: 16) {
                Button {
                    preferences.pinnedPanel.toggle()
                } label: {
                    Image(
                        systemName: preferences.pinnedPanel
                            ? "pin.circle.fill" : "pin.circle"
                    )
                    .imageScale(.large)
                    .frame(width: 18, height: 18)
                    .scaleEffect(1.15)
                    .animation(
                        .easeInOut(duration: 0.125),
                        value: preferences.pinnedPanel
                    )
                }
                .help("Pin the Panel")
                .accessibilityLabel("Pin the Panel")

                Button {
                    openSettings()
                } label: {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .frame(width: 18, height: 18)
                }
                .frame(width: 18, height: 18)
                .help("Open Settings")
                .accessibilityLabel("Open Settings")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, controlHorizontalPadding)
            .padding(.vertical, controlVerticalPadding)
            .modifier(CapsuleControlSurface(shape: Capsule()))

            Spacer()

            Button(action: { addingGroup = true }) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add Item")
            .padding(.horizontal, controlHorizontalPadding)
            .padding(.vertical, controlVerticalPadding)
            .modifier(CapsuleControlSurface(shape: Circle()))
            .popover(
                isPresented: $addingGroup,
                content: {
                    NewMind(addingItem: $addingItem) { text, group in
                        _ = addGroup(text)
                    }
                }
            )
        }
        .padding(.top, overlayTopInset)
        .padding(.horizontal, overlaySideInset)
    }

    @ViewBuilder
    private func signatureFooter(paddingTop: CGFloat) -> some View {
        if !preferences.hideSignatureLine {
            Group {
                if donationStore.hasDonated {
                    Text(preferences.signatureText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                } else {
                    Button {
                        openSettings()
                    } label: {
                        VStack {
                            Text(
                                "Support MindStack to unlock a custom signature"
                            )
                            .font(.caption)
                            .underline()
                            Text(
                                "(You can hide this)"
                            )
                            .font(.caption2)
                        }
                    }
                    .buttonStyle(.link)
                }
            }
            .padding(.top, paddingTop)
        }
    }
}

private struct CapsuleControlSurface<T: Shape>: ViewModifier {
    let shape: T

    func body(content: Content) -> some View {
        if #available(macOS 26, iOS 26, *) {
            content
                .glassEffect(in: shape)
        } else {
            content
                .background(.thinMaterial, in: shape)
                .shadow(color: .black.opacity(0.16), radius: 12, y: 6)
        }
    }
}

#Preview {
    MainPanel()
        .frame(width: 500, height: 600)
        .modelContainer(for: [ItemGroup.self, Item.self], inMemory: true)
        .environment(AppPreferences())
        .environment(DonationStore())
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppPreferences.self) private var preferences
    @Environment(DonationStore.self) private var donationStore
    @Environment(MenuBarController.self) private var menuBarController
    @Environment(\.openWindow) private var openWindow
    @State var showingPanel = false
    @State var hotKey: HotKey? = nil
    @State private var hasPresentedOnboarding = false

    var body: some View {
        @Bindable var preferences = preferences

        EmptyView()
            .frame(width: 0, height: 0)
            .onAppear {
                installHotKey()
                presentOnboardingIfNeeded()
                menuBarController.setMenuBarItemHidden(preferences.hideMenuBarItem)
            }
            .onDisappear {
                uninstallHotKey()
            }
            .onChange(of: preferences.shortcut, initial: false) { _, _ in
                installHotKey()
            }
            .onChange(of: preferences.hideMenuBarItem, initial: true) { _, isHidden in
                menuBarController.setMenuBarItemHidden(isHidden)
            }
            .task {
                for await _ in NotificationCenter.default.notifications(
                    named: .showMindStackMainPanel
                ) {
                    showPanel()
                }
            }
            .hidden()
            .floatingPanel(
                isPresented: $showingPanel,
                isPinned: $preferences.pinnedPanel
            ) {
                VisualEffectView(
                    material: .sidebar,
                    blendingMode: .behindWindow
                )
                .ignoresSafeArea(.all)
                .overlay {
                    MainPanel()
                        .environment(\.modelContext, modelContext)
                        .environment(preferences)
                        .environment(donationStore)
                }
            }
    }

    private func installHotKey() {
        uninstallHotKey()
        hotKey = HotKey(
            keyCombo: preferences.shortcut.keyCombo,
            keyDownHandler: togglePanel
        )
    }

    private func uninstallHotKey() {
        hotKey?.isPaused = true
        hotKey = nil
    }

    private func togglePanel() {
        if showingPanel {
            showingPanel = false
        } else {
            showPanel()
        }
    }

    private func showPanel() {
        NSApp.activate(ignoringOtherApps: true)
        showingPanel = true
    }

    private func presentOnboardingIfNeeded() {
        guard !preferences.hasSeenOnboarding, !hasPresentedOnboarding else {
            return
        }
        hasPresentedOnboarding = true
        preferences.hasSeenOnboarding = true
        openWindow(id: "welcome")
    }
}
