//
//  ContextFetchOperation.swift
//  RAD
//
//  Created by David Livadaru on 18/09/2018.
//  Copyright © 2018 National Public Radio. All rights reserved.
//

import Foundation
import CoreData

/// An operation which outputs the array of fetched NSManagedObject
/// based on the array of NSManagedObjectID.
class ContextFetchOperation<T: NSManagedObject>:
ChainOperation<[NSManagedObjectID], [T]> {
    private let context: NSManagedObjectContext

    /// - Parameter context: the context where objects are fetched into.
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override func execute() {
        guard let ids = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        context.perform {
            let objects = ids.compactMap({
                self.context.object(with: $0) as? T
            })
            self.finish(with: objects)
        }
    }
}
