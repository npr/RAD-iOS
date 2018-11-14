//
//  ProcessItemSessionsOperation.swift
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

class ProcessItemSessionsOperation: InputOperation<[ItemSession]> {
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
        guard let itemSessions = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        context.perform {
            self.performOperations(itemSessions: itemSessions)
        }
    }

    // MARK: Private functionality

    private func performOperations(itemSessions: [ItemSession]) {
        let saveOperation = SaveContextOperation(context: context)
        let cleanupOperation = ProcessItemCleanupOperation(
            context: context,
            sessionContext: sessionContext,
            configuration: configuration)
        cleanupOperation.completionBlock = { self.finish() }
        cleanupOperation.addDependency(saveOperation)
        var operations = [saveOperation, cleanupOperation]
        var previousFilterOperation: FilterEventsOperation?
        itemSessions.forEach({ itemSession in
            previousFilterOperation = self.process(
                itemSession,
                dependingOn: previousFilterOperation,
                with: saveOperation,
                from: &operations)
        })
        OperationQueue.background.addOperations(
            operations, waitUntilFinished: false)
    }

    private func process(
        _ itemSession: ItemSession,
        dependingOn previousFilter: FilterEventsOperation?,
        with saveOperation: Operation,
        from operations: inout [Operation]
    ) -> FilterEventsOperation? {
        guard let json: String = itemSession.sessionId?.rad?.json
            else { return nil }
        guard let ranges = itemSession.playbackRanges?.allObjects as? [Range]
            else { return nil }
        guard let sessionIdentifier = itemSession.sessionId?.identifier
            else { return nil }
        guard let md5 = itemSession.sessionId?.rad?.md5 else { return nil }

        let parseJson = ParseJSONOperation<JSONDictionary>()
        parseJson.input = json
        let parsePayload = ParseRADObjectsOperation(
            context: self.context,
            sessionId: sessionIdentifier,
            md5: md5)
        parsePayload.addDependency(previousFilter)
        parseJson.chainOperation(with: parsePayload)
        let filterEvents = FilterEventsOperation(
            ranges: ranges, context: context)
        parsePayload.chainOperation(with: filterEvents)
        operations += [parseJson, parsePayload, filterEvents]
        let deleteOperation: Operation

        if !itemSession.isActive {
            let deleteItemOperation = DeleteOperation<ItemSession>(
                context: context)
            deleteItemOperation.input = [itemSession]
            deleteOperation = deleteItemOperation
        } else {
            let deleteRangesOperation = DeleteOperation<Range>(
                context: context)
            deleteRangesOperation.input = ranges
            deleteOperation = deleteRangesOperation
        }

        deleteOperation.addDependency(filterEvents)
        saveOperation.addDependency(deleteOperation)
        operations.append(deleteOperation)

        return filterEvents
    }
}
