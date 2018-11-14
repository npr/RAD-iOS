//
//  ContextTransferOperation.swift
//  RAD
//
//  Created by David Livadaru on 17/08/2018.
//  Copyright © 2018 National Public Radio. All rights reserved.
//

import Foundation
import CoreData

/// An operation which outputs the object ids of an array of NSManagedObjectID.
class ContextTransferOperation<T: NSManagedObject>:
ChainOperation<[T], [NSManagedObjectID]> {
    private let context: NSManagedObjectContext

    /// - Parameter context: The context in which objects are fetched into.
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override func execute() {
        guard let objects = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        context.perform {
            let objectIds = objects.map({ $0.objectID })
            self.finish(with: objectIds)
        }
    }
}
