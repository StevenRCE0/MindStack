//
//  MindCard.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/21.
//

import SwiftUI

struct MindCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    var bold: Bool = false
    
    var fillStyle: some ShapeStyle {
        get {
            if colorScheme == .dark {
                return RadialGradient(stops: [.init(color: .init(white: 0.16), location: 0), .init(color: .init(white: 0.15), location: 0.2), .init(color: .init(white: 0.13), location: 0.65), .init(color: .init(white: 0.11), location: 1)], center: .init(x: 0.5, y: -0.9), startRadius: 190, endRadius: 300)
            } else {
                return RadialGradient(stops: [.init(color: .init(white: 0.96), location: 0), .init(color: .init(white: 0.93), location: 0.6), .init(color: .init(white: 0.91), location: 0.77), .init(color: .init(white: 0.86), location: 1)], center: .top, startRadius: 80, endRadius: 350)
            }
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: .init(width: 10, height: 10), style: .continuous)
                .fill(fillStyle)
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
