//
//  SaveContextOperation.swift
//  RAD
//
//  Created by David Livadaru on 16/08/2018.
//  Copyright © 2018 National Public Radio. All rights reserved.
//

import Foundation
import CoreData

/// Saves the contexts if it has pending changes.
class SaveContextOperation: Operation {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override func execute() {
        context.perform {
            guard self.context.hasChanges else {
                self.finish()
                return
            }

            Storage.shared?.save(context: self.context)
            self.finish()
        }
    }
}
