//
//  ProcessBatchesOperation.swift
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

class ProcessBatchesOperation:
ChainOperation<[Batch], UIBackgroundFetchResult> {
    private let configuration: Configuration
    private let context: NSManagedObjectContext

    init(configuration: Configuration, context: NSManagedObjectContext) {
        self.configuration = configuration
        self.context = context
    }

    override func execute() {
        guard let batches = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        let aggregationOperation = AggregateOperation()
        let finishOperation = ClosureInputOperation<UIBackgroundFetchResult>(
            closure: {
                self.finish(with: $0)
        })
        aggregationOperation.chainOperation(with: finishOperation)

        var operations: [Foundation.Operation] = [
            aggregationOperation, finishOperation
        ]

        batches.forEach {
            let conversionOperation = ConvertBatchOperation(
                configuration: configuration, context: context)
            conversionOperation.input = $0
            let networkOperation = NetworkOperation()
            conversionOperation.chainOperation(with: networkOperation)
            let responseCheckOperation = ResponseCheckOperation(
                context: context)
            networkOperation.chainOperation(with: responseCheckOperation)
            let batchCompletion =
                ClosureInputOperation<UIBackgroundFetchResult>(
                    closure: { [weak aggregationOperation] in
                        aggregationOperation?.add($0)
                })
            responseCheckOperation.chainOperation(with: batchCompletion)
            aggregationOperation.addDependency(batchCompletion)
            operations += [
                conversionOperation,
                networkOperation,
                responseCheckOperation,
                batchCompletion
            ]
        }

        OperationQueue.background.addOperations(
            operations, waitUntilFinished: false)

    }
}
