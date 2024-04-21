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
    var text: String = ""
    
    init(timestamp: Date, text: String) {
        self.timestamp = timestamp
        self.text = text
    }
}

@Model
final class ItemGroup {
    var timestamp: Date
    @Relationship(deleteRule: .cascade) var items: [Item]
    var name: String = ""
    
    
    init(timestamp: Date, name: String = "", items: [Item] = []) {
        self.timestamp = timestamp
        self.items = items
        self.name = name
    }
}
