//
//  Item.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
