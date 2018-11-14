//
//  TimezonedDate+CoreDataProperties.swift
//  RAD
//
//  Created by David Livadaru on 26/10/2018.
//  Copyright © 2018 NPR. All rights reserved.
//
//

import Foundation
import CoreData

extension TimezonedDate {

    @nonobjc class func fetchRequest() -> NSFetchRequest<TimezonedDate> {
        return NSFetchRequest<TimezonedDate>(entityName: "TimezonedDate")
    }

    @NSManaged var intervalSince1970: Double
    @NSManaged var timezoneOffset: Int64
    @NSManaged var event: Event?
    @NSManaged var metadataRelations: NSSet?
    @NSManaged var rangeBound: RangeBound?

}

// MARK: Generated accessors for metadataRelations
extension TimezonedDate {

    @objc(addMetadataRelationsObject:)
    @NSManaged func addToMetadataRelations(_ value: MetadataRelation)

    @objc(removeMetadataRelationsObject:)
    @NSManaged func removeFromMetadataRelations(_ value: MetadataRelation)

    @objc(addMetadataRelations:)
    @NSManaged func addToMetadataRelations(_ values: NSSet)

    @objc(removeMetadataRelations:)
    @NSManaged func removeFromMetadataRelations(_ values: NSSet)

}
