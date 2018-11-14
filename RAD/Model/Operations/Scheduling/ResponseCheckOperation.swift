//
//  ResponseCheckOperation.swift
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

class ResponseCheckOperation:
ChainOperation<NetworkResult, UIBackgroundFetchResult> {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override func execute() {
        guard let result = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }
        switch result.status.`class` {
        case .success, .client:
            let deleteRelations = BlockOperation(block: {
                self.context.performAndWait({
                    result.batch.groups.forEach({
                        $0.metadata.removeFromDates(NSSet(array: $0.dates))
                    })
                })
            })
            let saveOperation = SaveContextOperation(context: context)
            saveOperation.addDependency(deleteRelations)
            let completion = BlockOperation {
                self.finish(with: .newData)
            }
            completion.addDependency(saveOperation)
            OperationQueue.background.addOperations(
                [deleteRelations, saveOperation, completion],
                waitUntilFinished: false)
        default:
            self.finish(with: .noData)
        }
    }
}
