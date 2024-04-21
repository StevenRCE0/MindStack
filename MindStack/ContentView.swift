//
//  ContentView.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/17.
//

import SwiftUI
import SwiftData
import HotKey

struct MainPanel: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var groups: [ItemGroup]
    
    @State private var addingGroup = false
    @State private var addingItem: ItemGroup? = nil
    @State private var addingText = ""
    
    
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(groups, id: \.id) { group in
                    MindStack(group: group)
                }
            }
            .padding(30)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Spacer()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {addingGroup = true}) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .popover(isPresented: $addingGroup, content: {
                        TextField("New mind", text: $addingText)
                            .lineLimit(5)
                            .frame(width: 240)
                            .cornerRadius(10)
                            .padding()
                            .onSubmit {
                                withAnimation {
                                    addingGroup = false
                                    _ = addGroup(addingText)
                                }
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
        return newGroup
    }
    
    // MARK: - To implement
    private func deleteItems(offsets: IndexSet) {
        //        withAnimation {
        //            for index in offsets {
        //                modelContext.delete(cards[index])
        //            }
        //        }
    }
}

#Preview {
    MainPanel()
        .modelContainer(for: Item.self, inMemory: true)
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State var showingPanel = false
    
    @State var hotKey: HotKey? = nil
    
    var body: some View {
        EmptyView()
            .frame(width: 0, height: 0)
            .onAppear {
                if hotKey == nil {
                    hotKey = HotKey(key: .z, modifiers: [.shift, .control], keyDownHandler: {
                        if showingPanel {
                            showingPanel = false
                            print("should close")
                        } else {
                            NSApp.activate(ignoringOtherApps: true)
                            showingPanel = true
                        }
                    })
                }
            }
            .hidden()
            .floatingPanel(isPresented: $showingPanel) {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                    .overlay {
                        MainPanel()
                            .environment(\.modelContext, modelContext)
                        
                    }
            }
    }
}
