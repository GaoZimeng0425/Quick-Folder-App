//
//  Item.swift
//  QuickFolder
//
//  Created by GaoZimeng on 2025/1/3.
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
