//
//  Item.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import Foundation
import CoreData

@objc(Item) // Core Data와의 호환성을 위해 추가
public class Item: NSManagedObject {
    @NSManaged public var timestamp: Date?
}

// MARK: - Convenience Initializer
extension Item {
    convenience init(context: NSManagedObjectContext, timestamp: Date) {
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: context)!
        self.init(entity: entity, insertInto: context)
        self.timestamp = timestamp
    }
}
