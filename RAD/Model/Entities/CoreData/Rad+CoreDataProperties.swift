//
//  Rad+CoreDataProperties.swift
//  RAD
//
//  Created by David Livadaru on 26/10/2018.
//  Copyright © 2018 NPR. All rights reserved.
//
//

import Foundation
import CoreData

extension Rad {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Rad> {
        return NSFetchRequest<Rad>(entityName: "Rad")
    }

    @NSManaged var isLocked: Bool
    @NSManaged var json: String?
    @NSManaged var md5: String?
    @NSManaged var itemSessionIds: NSSet?

}

// MARK: Generated accessors for itemSessionIds
extension Rad {

    @objc(addItemSessionIdsObject:)
    @NSManaged func addToItemSessionIds(_ value: ItemSessionID)

    @objc(removeItemSessionIdsObject:)
    @NSManaged func removeFromItemSessionIds(_ value: ItemSessionID)

    @objc(addItemSessionIds:)
    @NSManaged func addToItemSessionIds(_ values: NSSet)

    @objc(removeItemSessionIds:)
    @NSManaged func removeFromItemSessionIds(_ values: NSSet)

}
