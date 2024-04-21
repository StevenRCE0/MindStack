//
//  MindStack.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/22.
//

import SwiftUI

struct MindStack: View {
    @Environment(\.modelContext) private var modelContext
    
    var group: ItemGroup
    @State private var pressureLevel: Float = 0.0
    @State private var pressureStage: Int = 0
    @State private var addingItem: ItemGroup? = nil
    @State private var addingText = ""
    
    @State private var scrollX: CGFloat = 0
    
    var normalizedDifference: (Double, Int) {
        var stageCount = (group.items.count - 1) * 2
        let travelStride = Float(1 / Float(stageCount))
        let travelStage = Int(floor(pressureLevel / travelStride))
        let x = (pressureLevel - (Float(travelStage) * travelStride)) / (2 * travelStride)
        
        var d: Double
        
        if travelStage.isMultiple(of: 2) {
            d = Double(1 - pow(1 - pow(2 * x, 3), 1 / 3)) / 2
        } else {
            d = Double(pow(1 + pow(2 * x - 1, 3), 1 / 3)) / 2
        }
        d += Double(travelStage) / 2
        return (d.isNormal ? d : 0, travelStage)
    }
    
    private func calculateOpacity(_ index: Int) -> Double {
        let gate = 0.6
        if (normalizedDifference.0 - Double(index) < gate) {
            return 1
        }
        return 1 - (normalizedDifference.0 - Double(index) - gate) * 5
    }
    
    private func calculateOffset(_ index: Int) -> CGFloat {
        if index <= Int(normalizedDifference.0) {
            return CGFloat(
                -pow(
                    CGFloat(
                        (normalizedDifference.0 - Double(index))
                    ) * 20,
                    2
                )
            )
        }
        return (normalizedDifference.0 - Double(index)) * -20
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if group.items.count > 1 {
                Text(group.items.sorted(by: {$0.timestamp > $1.timestamp}).last!.text)
                    .font(.title2.bold())
                    .foregroundStyle(Color(white: 0.3))
                    .blendMode(.hardLight)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 15, leading: 10, bottom: -15, trailing: 10))
            }
            ZStack {
                ForEach(Array(group.items.sorted(by: {$0.timestamp > $1.timestamp}).enumerated().reversed()), id: \.element) { index, card in
                    MindCard(text: .constant(card.text))
                        .offset(x: scrollX, y: calculateOffset(index))
                        .scaleEffect(CGFloat(1 + (normalizedDifference.0 - Double(index)) * 0.1))
                        .opacity(calculateOpacity(index))
                        .animation(.spring(), value: pressureLevel)
                }
                ForceTouchView { pressure, stage in
                    self.pressureLevel = pressure
                    self.pressureStage = stage
                }
                .onChange(of: normalizedDifference.1, initial: false) { value, _ in
                    if value % 2 == 0 {
                        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
                    }
                }
                .onChange(of: pressureStage, initial: false) { stage, _ in
                    if stage == 2 {
                        withAnimation {
                            addingItem = group
                        }
                    }
                }
            }
        }
        // handle secondary click
        .contextMenu {
            if group.items.count > 1 {
                Button("Pop") {
                    popItem(group: group)
                }
            }
            Button("Delete All") {
                deleteAllItems(group: group)
            }
            Divider()
            Button("Add New") {
                addingItem = group
            }
        }
        .popover(isPresented: Binding(get: {addingItem != nil}, set: { _ in addingItem = nil})) {
            EmptyView()
            TextField("New mind", text: $addingText)
                .lineLimit(5)
                .frame(width: 240)
                .cornerRadius(10)
                .padding()
                .onSubmit {
                    withAnimation {
                        addItem(addingText, group: addingItem!)
                        addingItem = nil
                    }
                }
        }
    }
    
    
    private func addItem(_ text: String, group: ItemGroup) {
        withAnimation {
            let newItem = Item(timestamp: Date(), text: text)
            group.items.append(newItem)
            try! modelContext.save()
        }
    }
    
    private func deleteAllItems(group: ItemGroup) {
        withAnimation(.easeIn) {
            modelContext.delete(group)
        }
    }
    
    private func popItem(group: ItemGroup) {
        withAnimation {
            if let toPop = group.items.sorted(by: {$0.timestamp > $1.timestamp}).first {
                group.items.remove(at: group.items.firstIndex(of: toPop)!)
                try! modelContext.save()
            }
        }
    }
}

//#Preview {
//    MindStack()
//}
