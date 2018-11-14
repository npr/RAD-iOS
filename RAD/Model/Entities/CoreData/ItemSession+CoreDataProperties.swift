//
//  ItemSession+CoreDataProperties.swift
//  RAD
//
//  Created by David Livadaru on 26/10/2018.
//  Copyright © 2018 NPR. All rights reserved.
//
//

import Foundation
import CoreData

extension ItemSession {

    @nonobjc class func fetchRequest() -> NSFetchRequest<ItemSession> {
        return NSFetchRequest<ItemSession>(entityName: "ItemSession")
    }

    @NSManaged var isActive: Bool
    @NSManaged var playbackRanges: NSSet?
    @NSManaged var sessionId: ItemSessionID?

}

// MARK: Generated accessors for playbackRanges
extension ItemSession {

    @objc(addPlaybackRangesObject:)
    @NSManaged func addToPlaybackRanges(_ value: Range)

    @objc(removePlaybackRangesObject:)
    @NSManaged func removeFromPlaybackRanges(_ value: Range)

    @objc(addPlaybackRanges:)
    @NSManaged func addToPlaybackRanges(_ values: NSSet)

    @objc(removePlaybackRanges:)
    @NSManaged func removeFromPlaybackRanges(_ values: NSSet)

}
