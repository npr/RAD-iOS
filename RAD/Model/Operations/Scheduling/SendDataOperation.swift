//
//  SendDataOperation.swift
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
import Reachability

class SendDataOperation: ChainOperation<[Server], UIBackgroundFetchResult> {
    private let configuration: Configuration
    private let context: NSManagedObjectContext
    private let reachability = Reachability()

    init(configuration: Configuration, context: NSManagedObjectContext) {
        self.configuration = configuration
        self.context = context
    }

    override func execute() {
        guard let servers = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        guard let connection = reachability?.connection, connection != .none
        else {
            Scheduling.last = Date()
            finish(with: .failed)
            return
        }

        let aggregationOperation = AggregateOperation()
        let finishOperation = ClosureInputOperation<UIBackgroundFetchResult>(
            closure: {
                self.setOutput($0)
                Scheduling.last = Date()
                self.finish()
        })
        aggregationOperation.chainOperation(with: finishOperation)

        var operations: [Foundation.Operation] = [
            aggregationOperation, finishOperation
        ]

        servers.forEach({
            let batchOperation = BatchEventsOperation(
                configuration: configuration, server: $0, context: context)
            let processBatchOperation = ProcessBatchesOperation(
                configuration: configuration, context: context)
            batchOperation.chainOperation(with: processBatchOperation)

            let processCompletion =
                ClosureInputOperation<UIBackgroundFetchResult>(
                    closure: { [weak aggregationOperation] in
                        aggregationOperation?.add($0)
                })
            processBatchOperation.chainOperation(with: processCompletion)
            aggregationOperation.addDependency(processCompletion)

            operations += [
                batchOperation, processBatchOperation, processCompletion
            ]
        })

        let cleanupOperation = SendDataCleanupOperation(context: context)
        cleanupOperation.addDependency(aggregationOperation)
        let saveOperation = SaveContextOperation(context: context)
        saveOperation.addDependency(cleanupOperation)

        operations += [cleanupOperation, saveOperation]
        finishOperation.addDependency(saveOperation)

        OperationQueue.background.addOperations(
            operations, waitUntilFinished: false)
    }
}
