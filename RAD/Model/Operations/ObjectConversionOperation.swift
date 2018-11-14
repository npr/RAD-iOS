//
//  ObjectConversionOperation.swift
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

import CoreData

class ObjectConversionOperation<T: NSManagedObject & ObjectConvertible>:
ChainOperation<[T], [Object]> {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override func execute() {
        guard let databaseObjects = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }
        context.perform {
            let convertedObjects = databaseObjects.map({ $0.object })
            self.finish(with: convertedObjects)
        }
    }
}
