//
//  NewMind.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/22.
//

import SwiftUI

struct NewMind: View {
    @Binding var addingItem: ItemGroup?
    @State private var addingText: String = ""
    var addItem: (String, ItemGroup?) -> Void
    
    var body: some View {
        TextField("New Mind", text: $addingText)
            .lineLimit(5)
            .frame(width: 240)
            .cornerRadius(10)
            .padding()
            .onSubmit {
                withAnimation {
                    addItem(addingText, addingItem)
                    addingItem = nil
                    addingText = ""
                }
            }
    }
}

#Preview {
    NewMind(addingItem: .constant(nil), addItem: {_,_ in})
}
