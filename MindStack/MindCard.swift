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
                .fill(.radialGradient(stops: [.init(color: .init(white: 0.96), location: 0), .init(color: .init(white: 0.93), location: 0.2), .init(color: .init(white: 0.91), location: 0.65), .init(color: .init(white: 0.86), location: 1)], center: .top, startRadius: 80, endRadius: 300))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.27),radius: 10, y: 4)
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
