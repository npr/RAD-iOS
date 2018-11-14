//
//  DatabaseFetcher.swift
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

struct DatabaseFetcher {
    typealias Completion = ([Object]) -> Void

    private let mainContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext

    init(
        mainContext: NSManagedObjectContext,
        backgroundContext: NSManagedObjectContext
    ) {
        self.mainContext = mainContext
        self.backgroundContext = backgroundContext
    }

    /// Fetch objects from database for specified type.
    ///
    /// - Parameters:
    ///   - type: The type of objects to fetch.
    ///   - completion: The handler called upon finihsing the fetch.
    func fetchObjects(
        for type: ObjectType, completion: @escaping Completion
    ) {
        switch type {
        case .event:
            executeFetch(for: Event.self, completion: completion)
        case .itemSession:
            executeFetch(for: ItemSession.self, completion: completion)
        case .itemSessionId:
            executeFetch(for: ItemSessionID.self, completion: completion)
        case .rad:
            executeFetch(for: Rad.self, completion: completion)
        case .radMetadata:
            executeFetch(for: RadMetadata.self, completion: completion)
        case .metadataRelation:
            executeFetch(for: MetadataRelation.self, completion: completion)
        case .range:
            executeFetch(for: Range.self, completion: completion)
        case .rangeBound:
            executeFetch(for: RangeBound.self, completion: completion)
        case .server:
            executeFetch(for: Server.self, completion: completion)
        case .timezonedDate:
            executeFetch(for: TimezonedDate.self, completion: completion)
        }
    }

    /// Fetch objects with specified object ids.
    ///
    /// - Parameters:
    ///   - ids: The NSManagedObjectIDs.
    ///   - completion: The completion handler.
    func fetchObjects(
        with ids: [NSManagedObjectID], completion: @escaping Completion
    ) {
        self.mainContext.perform {
            let objects: [Object] = ids.compactMap({
                let fetchedObject = self.mainContext.object(with: $0)
                let convertibleObject = fetchedObject as? ObjectConvertible
                return convertibleObject?.object
            })
            completion(objects)
        }
    }

    // MARK: Private functionality

    /// Peform a fetch for a generic database type.
    ///
    /// - Parameters:
    ///   - type: The type to fetch.
    ///   - completion: The completion handler.
    private func executeFetch<T: NSManagedObject & ObjectConvertible>(
        for type: T.Type, completion: @escaping Completion
    ) {
        let fetchOperation = FetchOperation<T>(context: backgroundContext)
        fetchOperation.completionBlock = { [weak fetchOperation] in
            if fetchOperation?.finishError != nil {
                completion([])
            }
        }

        let transferOperation = ContextTransferOperation<T>(
            context: backgroundContext)
        fetchOperation.chainOperation(with: transferOperation)

        let contextFetchOperation = ContextFetchOperation<T>(
            context: mainContext)
        transferOperation.chainOperation(with: contextFetchOperation)

        let conversionOperation = ObjectConversionOperation<T>(
            context: mainContext)
        contextFetchOperation.chainOperation(with: conversionOperation)

        let closureOperation = ClosureInputOperation<[Object]>(
            closure: completion)
        conversionOperation.chainOperation(with: closureOperation)

        OperationQueue.background.addOperations(
            [fetchOperation, transferOperation, contextFetchOperation],
            waitUntilFinished: false)
        OperationQueue.main.addOperations(
            [conversionOperation, closureOperation], waitUntilFinished: false)
    }
}
