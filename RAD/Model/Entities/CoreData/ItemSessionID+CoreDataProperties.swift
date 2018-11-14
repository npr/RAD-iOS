//
//  ItemSessionID+CoreDataProperties.swift
//  RAD
//
//  Created by David Livadaru on 26/10/2018.
//  Copyright © 2018 NPR. All rights reserved.
//
//

import Foundation
import CoreData

extension ItemSessionID {

    @nonobjc class func fetchRequest() -> NSFetchRequest<ItemSessionID> {
        return NSFetchRequest<ItemSessionID>(entityName: "ItemSessionID")
    }

    @NSManaged var creationIntervalSince1970: Double
    @NSManaged var identifier: String?
    @NSManaged var isLocked: Bool
    @NSManaged var itemSessions: NSSet?
    @NSManaged var rad: Rad?

}

// MARK: Generated accessors for itemSessions
extension ItemSessionID {

    @objc(addItemSessionsObject:)
    @NSManaged func addToItemSessions(_ value: ItemSession)

    @objc(removeItemSessionsObject:)
    @NSManaged func removeFromItemSessions(_ value: ItemSession)

    @objc(addItemSessions:)
    @NSManaged func addToItemSessions(_ values: NSSet)

    @objc(removeItemSessions:)
    @NSManaged func removeFromItemSessions(_ values: NSSet)

}
