//
//  MindCard.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/21.
//

import SwiftUI

struct MindCard: View {
    @Binding var text: String
    var bold: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: .init(width: 10, height: 10), style: .continuous)
                .fill(Color(white: 0.95))
                .shadow(radius: 10)
                .frame(width: 260, height: 180)
            Text(text)
                .font(.title3)
                .bold(bold)
                .padding()
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    MindCard(text: .constant("Hello"))
}
