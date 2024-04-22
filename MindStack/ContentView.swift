//
//  ContentView.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/17.
//

import SwiftUI
import SwiftData
import HotKey
import Defaults

struct MainPanel: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var groups: [ItemGroup]
    
    @Binding var pinnedPanel: Bool {
        didSet {
            Defaults[.pinnedPanel] = pinnedPanel
        }
    }
    @State private var addingGroup = false
    @State private var addingItem: ItemGroup? = nil
    
    private var sortedGroups: [ItemGroup] {
        groups.sorted(by: {$0.timestamp > $1.timestamp}).sorted(by: {$0.pinned && !$1.pinned})
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(sortedGroups, id: \.id) { group in
                    MindStack(group: group)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 30, bottom: 40, trailing: 30))
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        pinnedPanel.toggle()
                    }) {
                        Label(
                            "Pin the Panel",
                            systemImage: pinnedPanel ? "pin.circle.fill" : "pin.circle"
                        )
                        .scaleEffect(1.15)
                        .animation(.easeInOut(duration: 0.125), value: pinnedPanel)
                    }
                    .offset(x: -10)
                }
                ToolbarItem(placement: .primaryAction) {
                    Spacer()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {addingGroup = true}) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .popover(isPresented: $addingGroup, content: {
                        NewMind(addingItem: $addingItem) { text, group in
                            _ = addGroup(text)
                        }
                    })
                }
            }
        }
        .animation(.easeInOut, value: groups)
    }
    
    private func addGroup(_ text: String) -> ItemGroup {
        let newGroup = ItemGroup(timestamp: Date(), items: [.init(timestamp: Date(), text: text)])
        withAnimation {
            modelContext.insert(newGroup)
        }
        try! modelContext.save()
        return newGroup
    }
}

#Preview {
    MainPanel(pinnedPanel: .constant(false))
        .frame(width: 500, height: 600)
        .modelContainer(for: [ItemGroup.self, Item.self], inMemory: true)
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State var showingPanel = false
    @State var pinnedPanel: Bool = Defaults[.pinnedPanel]
    @State var hotKey: HotKey? = nil
    
    var body: some View {
        EmptyView()
            .frame(width: 0, height: 0)
            .onAppear {
                if hotKey == nil {
                    hotKey = HotKey(key: .z, modifiers: [.shift, .control], keyDownHandler: {
                        if showingPanel {
                            showingPanel = false
                        } else {
                            NSApp.activate(ignoringOtherApps: true)
                            showingPanel = true
                        }
                    })
                }
            }
            .hidden()
            .floatingPanel(isPresented: $showingPanel, isPinned: $pinnedPanel) {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                    .overlay {
                        MainPanel(
                            pinnedPanel: $pinnedPanel
                        )
                        .environment(\.modelContext, modelContext)
                    }
            }
    }
}
