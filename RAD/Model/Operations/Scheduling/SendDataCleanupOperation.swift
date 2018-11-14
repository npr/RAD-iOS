//
//  SendDataCleanupOperation.swift
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

class SendDataCleanupOperation: Operation {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override func execute() {
        var operations = createTimezonedDateOperations()
        operations += createOperations(
            for: Event.self,
            withRelation: "dates",
            dependentOn: operations.last)
        operations += createOperations(
            for: MetadataRelation.self,
            withRelation: "dates",
            dependentOn: operations.last)
        operations += createOperations(
            for: RadMetadata.self,
            withRelation: "metadataRelations",
            dependentOn: operations.last)
        operations += createOperations(
            for: Server.self,
            withRelation: "metadataRelations",
            dependentOn: operations.last)
        let completion = BlockOperation {
            self.finish()
        }
        operations.forEach({
            completion.addDependency($0)
        })
        operations.append(completion)

        OperationQueue.background.addOperations(
            operations, waitUntilFinished: false)
    }

    private func createOperations<T: NSManagedObject>(
        for type: T.Type,
        withRelation relation: String,
        dependentOn dependentOperation: Foundation.Operation? = nil
    ) -> [Foundation.Operation] {
        let predicateOperation = CreateEmptyObjectPredicateOperation(
            relation: relation)
        predicateOperation.addDependency(dependentOperation)
        let fetchOperation = FetchOperation<T>(context: context)
        predicateOperation.chainOperation(with: fetchOperation)
        let deleteOperation = DeleteOperation<T>(context: context)
        fetchOperation.chainOperation(with: deleteOperation)

        return [predicateOperation, fetchOperation, deleteOperation]
    }

    private func createTimezonedDateOperations(
        dependentOn dependentOperation: Foundation.Operation? = nil
    ) -> [Foundation.Operation] {
        let predicateOperation = CreateEmptyObjectPredicateOperation(
            relation: "metadataRelations")
        predicateOperation.addDependency(dependentOperation)
        let timezonedDatePredicateOperation =
            SentTimezonedDatePredicateOperation()
        predicateOperation.chainOperation(with: timezonedDatePredicateOperation)
        let fetchOperation = FetchOperation<TimezonedDate>(context: context)
        timezonedDatePredicateOperation.chainOperation(with: fetchOperation)
        let deleteOperation = DeleteOperation<TimezonedDate>(context: context)
        fetchOperation.chainOperation(with: deleteOperation)

        return [
            timezonedDatePredicateOperation,
            predicateOperation,
            fetchOperation,
            deleteOperation]
    }
}
