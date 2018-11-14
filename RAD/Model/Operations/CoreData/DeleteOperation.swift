//
//  DeleteOperation.swift
//  RAD
//
//  Created by David Livadaru on 20/08/2018.
//  Copyright © 2018 National Public Radio. All rights reserved.
//

import Foundation
import CoreData

/// Deletes an array of input NSManagedObjects from context.
class DeleteOperation<T: NSManagedObject>: InputOperation<[T]> {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override func execute() {
        guard let objects = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        context.perform {
            self.context.deleteObjects(objects)
            self.finish()
        }
    }
}
