//
//  LockSessionOperation.swift
//  RAD
//
//  Copyright 2018 NPR
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//  this file except in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

import Foundation
import CoreData

class LockSessionOperation: InputOperation<[ItemSessionID]> {
    private let lock: Bool
    private let context: NSManagedObjectContext

    init(lock: Bool = true, context: NSManagedObjectContext) {
        self.lock = lock
        self.context = context
    }

    override func execute() {
        guard let objects = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }
        context.perform {
            objects.forEach({
                $0.isLocked = self.lock
            })
            self.finish()
        }
    }
}
