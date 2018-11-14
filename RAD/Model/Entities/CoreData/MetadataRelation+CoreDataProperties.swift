//
//  MetadataRelation+CoreDataProperties.swift
//  RAD
//
//  Created by David Livadaru on 26/10/2018.
//  Copyright © 2018 NPR. All rights reserved.
//
//

import Foundation
import CoreData

extension MetadataRelation {

    @nonobjc class func fetchRequest() -> NSFetchRequest<MetadataRelation> {
        return NSFetchRequest<MetadataRelation>(entityName: "MetadataRelation")
    }

    @NSManaged var sessionId: String?
    @NSManaged var dates: NSSet?
    @NSManaged var radMetadata: RadMetadata?
    @NSManaged var server: Server?

}

// MARK: Generated accessors for dates
extension MetadataRelation {

    @objc(addDatesObject:)
    @NSManaged func addToDates(_ value: TimezonedDate)

    @objc(removeDatesObject:)
    @NSManaged func removeFromDates(_ value: TimezonedDate)

    @objc(addDates:)
    @NSManaged func addToDates(_ values: NSSet)

    @objc(removeDates:)
    @NSManaged func removeFromDates(_ values: NSSet)

}
