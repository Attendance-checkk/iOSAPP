//
//  Item.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
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
