//
//  CreateItemSessionOperation.swift
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

class CreateItemSessionOperation: ChainOperation<String, ItemSession> {
    private typealias FetchCompletion = (FetchedSessionData) -> Void
    private typealias Completion = () -> Void

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
        guard let radPayload = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        guard let md5Hash = radPayload.md5 else {
            finish(with: OutputError.computationError)
            return
        }

        fetchData(for: md5Hash) { fetchedData in
            self.context.perform {
                let sessionData = self.extractSessionData(
                    with: radPayload, md5Hash: md5Hash, from: fetchedData)

                let itemSession = ItemSession(context: self.context)
                itemSession.sessionId = sessionData.sessionId

                Storage.shared?.save(context: self.context)

                self.unlockObjects(
                    startingWith: sessionData.sessionId, unlockCompletion: {
                        self.finish(with: itemSession)
                })
            }
        }
    }

    private func fetchData(
        for md5Hash: String, fetchCompletion: @escaping FetchCompletion
    ) {
        let radOperations = fetchRadOperations(with: md5Hash)
        let sessionIdOperations = fetchSessionIDOperations(
            fetchRad: radOperations.fetch)

        var operations = radOperations.all
        operations += sessionIdOperations.all

        let completionOperation = BlockOperation {
            fetchCompletion(FetchedSessionData(
                rad: radOperations.contextFetch.output?.first,
                sessionId: sessionIdOperations.contextFetch.output?.first))
        }
        operations.forEach({
            completionOperation.addDependency($0)
        })
        operations.append(completionOperation)

        OperationQueue.background.addOperations(
            operations, waitUntilFinished: false)
    }

    private func extractSessionData(
        with payload: String,
        md5Hash: String,
        from optionalSessionData: FetchedSessionData
    ) -> SessionData {
        let createItemSessionId = { (_ rad: Rad) -> ItemSessionID in
            let sessionId = ItemSessionID(context: self.context)
            sessionId.creationIntervalSince1970 = Date.now.timeIntervalSince1970
            sessionId.identifier = UUID().uuidString
            sessionId.rad = rad
            return sessionId
        }

        let rad: Rad
        let itemSessionId: ItemSessionID

        if let fetchedRad = optionalSessionData.rad {
            rad = fetchedRad
            if let fetchedItemSession = optionalSessionData.sessionId {
                itemSessionId = fetchedItemSession
            } else {
                itemSessionId = createItemSessionId(rad)
            }
        } else {
            rad = Rad(context: context)
            rad.json = payload
            rad.md5 = md5Hash
            itemSessionId = createItemSessionId(rad)
        }

        return SessionData(rad: rad, sessionId: itemSessionId)
    }

    private func fetchRadOperations(
        with md5Hash: String
    ) -> FetchedTypeOperations<Rad> {
        let fetchRad = FetchOperation<Rad>(context: sessionContext)
        fetchRad.input = NSPredicate(
            format: "md5 == %@", argumentArray: [md5Hash]
        )
        let lockRad = LockRadOperation(context: sessionContext)
        fetchRad.chainOperation(with: lockRad)

        let saveSessionContext = SaveContextOperation(context: sessionContext)
        saveSessionContext.addDependency(lockRad)

        let transferRad = ContextTransferOperation<Rad>(context: sessionContext)
        fetchRad.chainOperation(with: transferRad)
        transferRad.addDependency(saveSessionContext)

        let contextFetchRad = ContextFetchOperation<Rad>(context: context)
        transferRad.chainOperation(with: contextFetchRad)

        return FetchedTypeOperations<Rad>(
            fetch: fetchRad,
            contextFetch: contextFetchRad,
            all: [
                fetchRad,
                lockRad,
                saveSessionContext,
                transferRad,
                contextFetchRad
            ])
    }

    private func fetchSessionIDOperations(
        fetchRad: FetchOperation<Rad>
    ) -> FetchedTypeOperations<ItemSessionID> {
        let itemSessionPredicate = CreateValidSessionPredicateOperation(
            configuration: configuration)
        fetchRad.chainOperation(with: itemSessionPredicate)

        let fetchItemSessionId = FetchOperation<ItemSessionID>(
            context: sessionContext)

        itemSessionPredicate.chainOperation(with: fetchItemSessionId)
        let lockSession = LockSessionOperation(context: sessionContext)
        fetchItemSessionId.chainOperation(with: lockSession)

        let saveSessionContext = SaveContextOperation(context: sessionContext)
        saveSessionContext.addDependency(lockSession)

        let transferSessionId = ContextTransferOperation<ItemSessionID>(
            context: sessionContext)
        fetchItemSessionId.chainOperation(with: transferSessionId)
        transferSessionId.addDependency(saveSessionContext)

        let contextFetchSessionId = ContextFetchOperation<ItemSessionID>(
            context: context)
        transferSessionId.chainOperation(with: contextFetchSessionId)

        return FetchedTypeOperations<ItemSessionID>(
            fetch: fetchItemSessionId,
            contextFetch: contextFetchSessionId,
            all: [
                itemSessionPredicate,
                fetchItemSessionId,
                lockSession,
                saveSessionContext,
                transferSessionId,
                contextFetchSessionId
            ])
    }

    private func unlockObjects(
        startingWith itemSessionId: ItemSessionID,
        unlockCompletion: @escaping Completion
    ) {
        let contextTransfer = ContextTransferOperation<ItemSessionID>(
            context: context)
        contextTransfer.input = [itemSessionId]

        let sessionContext = self.sessionContext
        let contextFetch = ContextFetchOperation<ItemSessionID>(
            context: sessionContext)
        contextTransfer.chainOperation(with: contextFetch)

        let unlockOperation = AsyncClosureInputOperation<[ItemSessionID]>(
            closure: { ids, completion in
                sessionContext.perform {
                    ids.forEach({
                        $0.isLocked = false
                        $0.rad?.isLocked = false
                    })
                    completion()
                }
        })
        contextFetch.chainOperation(with: unlockOperation)

        let saveOperation = SaveContextOperation(context: sessionContext)
        saveOperation.completionBlock = {
            unlockCompletion()
        }
        saveOperation.addDependency(unlockOperation)

        OperationQueue.background.addOperations(
            [contextTransfer, contextFetch, unlockOperation, saveOperation],
            waitUntilFinished: false)
    }
}

private struct FetchedSessionData {
    let rad: Rad?
    let sessionId: ItemSessionID?
}

private struct SessionData {
    let rad: Rad
    let sessionId: ItemSessionID
}

private struct FetchedTypeOperations<Type: NSManagedObject> {
    let fetch: FetchOperation<Type>
    let contextFetch: ContextFetchOperation<Type>
    let all: [Foundation.Operation]
}
