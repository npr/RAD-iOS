//
//  ProcessItemCleanupOperation.swift
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

class ProcessItemCleanupOperation: Operation {
    private let context: NSManagedObjectContext
    private let sessionContext: NSManagedObjectContext
    private let configuration: Configuration

    init(
        context: NSManagedObjectContext,
        sessionContext: NSManagedObjectContext,
        configuration: Configuration
    ) {
        self.context = context
        self.sessionContext = sessionContext
        self.configuration = configuration
    }

    override func execute() {
        let itemOperations = createItemSessionOperations()
        let radOperations = createRadOperations(
            dependentWith: itemOperations.last)

        let saveOperation = SaveContextOperation(context: context)
        saveOperation.completionBlock = {
            self.finish()
        }
        saveOperation.addDependency(itemOperations.last)
        saveOperation.addDependency(radOperations.last)

        var operations = itemOperations
        operations += radOperations
        operations += saveOperation

        OperationQueue.background.addOperations(
            operations, waitUntilFinished: false)
    }

    // MARK: Private functionality

    private func createItemSessionOperations() -> [Foundation.Operation] {
        let predicateOperation = OldItemSessionIDOperation(
            configuration: configuration)
        let fetchItemSessionIDs = FetchOperation<ItemSessionID>(
            context: sessionContext)
        predicateOperation.chainOperation(with: fetchItemSessionIDs)
        let transferItemSessionIDs = ContextTransferOperation<ItemSessionID>(
            context: sessionContext)
        fetchItemSessionIDs.chainOperation(with: transferItemSessionIDs)
        let sessionContextFetch = ContextFetchOperation<ItemSessionID>(
            context: context)
        transferItemSessionIDs.chainOperation(with: sessionContextFetch)
        let deleteItemSessionIds = DeleteOperation<ItemSessionID>(
            context: context)
        sessionContextFetch.chainOperation(with: deleteItemSessionIds)
        let saveOperation = SaveContextOperation(context: context)
        saveOperation.addDependency(deleteItemSessionIds)

        return [
            predicateOperation,
            fetchItemSessionIDs,
            transferItemSessionIDs,
            sessionContextFetch,
            deleteItemSessionIds,
            saveOperation]
    }

    private func createRadOperations(
        dependentWith dependent: Foundation.Operation?
    ) -> [Foundation.Operation] {
        let createRadPredicate = UnlockedRadPredicateOperation()
        if let dependent = dependent {
            createRadPredicate.addDependency(dependent)
        }
        let fetchRadObjects = FetchOperation<Rad>(context: sessionContext)
        createRadPredicate.chainOperation(with: fetchRadObjects)
        let transferRad = ContextTransferOperation<Rad>(context: sessionContext)
        fetchRadObjects.chainOperation(with: transferRad)
        let radContextFetch = ContextFetchOperation<Rad>(context: context)
        transferRad.chainOperation(with: radContextFetch)
        let deleteRadObjects = DeleteOperation<Rad>(context: context)
        radContextFetch.chainOperation(with: deleteRadObjects)

        return [
            createRadPredicate,
            fetchRadObjects,
            transferRad,
            radContextFetch,
            deleteRadObjects]
    }
}
