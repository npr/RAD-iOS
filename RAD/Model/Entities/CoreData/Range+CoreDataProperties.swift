//
//  Range+CoreDataProperties.swift
//  RAD
//
//  Created by David Livadaru on 26/10/2018.
//  Copyright © 2018 NPR. All rights reserved.
//
//

import Foundation
import CoreData

extension Range {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Range> {
        return NSFetchRequest<Range>(entityName: "Range")
    }

    @NSManaged var end: RangeBound?
    @NSManaged var itemSession: ItemSession?
    @NSManaged var start: RangeBound?

}
