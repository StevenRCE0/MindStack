//
//  MindStack.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/22.
//

import SwiftUI
import SwiftData

struct MindStack: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @Query private var groups: [ItemGroup]
    
    var group: ItemGroup
    @State private var pressureLevel: Float = 0.0
    @State private var pressureStage: Int = 0
    @State private var addingItem: ItemGroup? = nil
    
    @State private var scrollX: CGFloat = 0
    @State private var popped: [PersistentIdentifier] = []
    
    @State private var swipeActionTimer: Timer?
    private let swipeToPopThreshold: CGFloat = -220
    
    private var sortedItems: [Item] {
        group.items.sorted(by: {$0.timestamp > $1.timestamp})
    }
    
    private func calculateSwipeOffset() {
        if scrollX < swipeToPopThreshold {
            withAnimation(.spring(.snappy)) {
                popped.append(sortedItems.first!.id)
                popItem(group: group)
                scrollX = 0
            }
        } else {
            withAnimation(.spring(.snappy)) {
                scrollX = 0
            }
        }
    }
    
    var normalizedDifference: (Double, Int) {
        let stageCount = (group.items.count - 1) * 2
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
    
    private func actionHapticFeedback() {
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            count += 1
            if count == 4 {
                timer.invalidate()
            }
            NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        }
    }
    
    private func calculateOffsetX(card: Item, index: Int) -> CGFloat {
        if popped.contains(card.id) {
            return -300
        } else {
            if index == 0 {
                if scrollX > 0 {
                    return 10 * log10(scrollX + 1)
                } else {
                    return scrollX
                }
            } else {
                return 0
            }
        }
    }
    
    private func calculateScale(_ index: Int) -> CGFloat {
        return CGFloat(1 + (normalizedDifference.0 - Double(index)) * 0.1)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if group.items.count > 1 {
                Text(sortedItems.last!.text)
                    .font(.title2.bold())
                    .foregroundStyle(.foreground.opacity(0.7))
                    .blendMode(.hardLight)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 15, leading: 10, bottom: -10, trailing: 10))
            } else {
                Rectangle()
                    .opacity(0)
                    .frame(height: 10)
            }
            ZStack {
                ForEach(Array(sortedItems).enumerated().reversed(), id: \.element) { index, card in
                    MindCard(text: .constant(card.text), bold: index == group.items.count - 1, textSelection: .init(index == 0))
                        .offset(x: calculateOffsetX(card: card, index: index), y: calculateOffset(index))
                        .scaleEffect(calculateScale(index))
                        .opacity(calculateOpacity(index))
                        .animation(.spring(), value: pressureLevel)
                        .overlay(alignment: .center) {
                            if group.pinned && index == 0 {
                                RoundedRectangle(cornerSize: .init(width: 10, height: 10), style: .continuous)
                                    .fill(Color.init(white: 1, opacity: 0))
                                    .stroke(colorScheme == .light ? Color.yellow : Color.orange, lineWidth: 5)
                                    .opacity(colorScheme == .light ? 1 : 0.6)
                                    .shadow(color: colorScheme == .light ? Color.yellow : Color.orange, radius: 10)
                                    .frame(width: 260, height: 180)
                            } else {
                                EmptyView()
                            }
                        }
                }
                ForceTouchView { pressure, stage in
                    self.pressureLevel = pressure
                    self.pressureStage = stage
                } swipe: { event, touches in
                    if abs(event.deltaX) < abs(event.deltaY) {
                        return
                    }
                    scrollX += event.deltaX
                    if scrollX < swipeToPopThreshold {
                        if touches?.isEmpty ?? false {
                            calculateSwipeOffset()
                        }
                    }
                    swipeActionTimer?.invalidate()
                    if touches?.isEmpty ?? true {
                        swipeActionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                            calculateSwipeOffset()
                        }
                    }
                }
                .onChange(of: normalizedDifference.1, initial: false) { _, value in
                    if value > 1 && value < 2 * group.items.count - 3 && value % 2 == 0 {
                        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                    }
                }
                .onChange(of: pressureStage, initial: false) { _ , stage in
                    if stage == 2 {
                        if group.items.count < 5 {
                            NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
                            withAnimation {
                                addingItem = group
                            }
                        } else {
                            actionHapticFeedback()
                        }
                    }
                }
            }
        }
        .contextMenu {
            Button(group.pinned ? "Unpin" : "Pin") {
                withAnimation {
                    if !group.pinned {
                        for group in groups.filter({$0.pinned}) {
                            group.pinned = false
                        }
                    }
                    group.pinned.toggle()
                    try! modelContext.save()
                }
            }
            if group.items.count > 1 {
                Button("Pop") {
                    popItem(group: group)
                }
            }
            Divider()
            if group.items.count < 5 {
                Button("Add New") {
                    addingItem = group
                }
                Divider()
            }
            Button("Delete All") {
                deleteAllItems(group: group)
            }
        }
        .popover(isPresented: Binding(get: {addingItem != nil}, set: { _ in addingItem = nil})) {
            NewMind(addingItem: $addingItem) { text, group in
                addItem(text, group: group!)
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
            if let toPop = sortedItems.first {
                group.items.remove(at: group.items.firstIndex(of: toPop)!)
                if group.items.isEmpty {
                    modelContext.delete(group)
                }
                try! modelContext.save()
            }
        }
    }
}
