//
//  ItemSessionOperation.swift
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

import AVFoundation
import CoreData

protocol ItemSessionOperationDelegate: AnyObject {
    func itemSessionOperationSaveCompletionOperation(
        _ itemSessionOperation: ItemSessionOperation
    ) -> InputOperation<[NSManagedObjectID]>
}

class ItemSessionOperation: Operation, TimeRangeControllerDelegate {
    weak var delegate: ItemSessionOperationDelegate?

    private let asset: AVAsset
    private let player: AVPlayer
    private var itemSession: ItemSession?
    private var creationOperation: CreateItemSessionOperation?
    private weak var lastSaveOperation: Operation?
    private let timeRangeController: TimeRangeController
    private let configuration: Configuration

    init(asset: AVAsset, player: AVPlayer, configuration: Configuration) {
        self.asset = asset
        self.player = player
        self.configuration = configuration
        self.timeRangeController = TimeRangeController(player: player)

        super.init()

        timeRangeController.delegate = self
    }

    override func execute() {
        guard let context = Storage.shared?.createContext else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        guard let sessionContext = Storage.shared?.sessionContext else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        let parseOperation = ParseRADPayloadOperation(asset: asset)
        let createItemOperation = CreateItemSessionOperation(
            context: context,
            sessionContext: sessionContext,
            configuration: configuration)
        parseOperation.chainOperation(with: createItemOperation)
        self.creationOperation = createItemOperation

        let createCompletion = ClosureInputOperation<ItemSession>(
            closure: { itemSession in
                self.itemSession = itemSession
                self.creationOperation = nil
        })
        createItemOperation.chainOperation(with: createCompletion)

        OperationQueue.background.addOperations(
            [parseOperation], waitUntilFinished: false)
        OperationQueue.itemSession.addOperations(
            [createItemOperation, createCompletion], waitUntilFinished: false)
    }

    // MARK: TimeRangeControllerDelegate

    func timeRangeController(
        _ timeRangeController: TimeRangeController,
        didCreateTimeRange timeRange: TimeRange,
        synced: Bool
    ) {
        guard let context = Storage.shared?.createContext else { return }

        OperationQueue.itemSession.addOperations(
            [BlockOperation(block: {
                guard self.itemSession != nil || self.creationOperation != nil
                    else { return }

                let convertOperation = ConvertTimeRangeOperation(
                    timeRange: timeRange, context: context)
                if let itemSession = self.itemSession {
                    convertOperation.input = itemSession
                } else {
                    self.creationOperation?.chainOperation(
                        with: convertOperation)
                }

                let saveOperation = SaveContextOperation(context: context)
                saveOperation.addDependency(convertOperation)
                self.lastSaveOperation = saveOperation
                let transferOperation = ContextTransferOperation<Range>(
                    context: context)
                transferOperation.addDependency(saveOperation)
                convertOperation.chainOperation(with: transferOperation)

                var operations: [Operation] = [
                    convertOperation, saveOperation, transferOperation]
                if let completion =
                    self.delegate?.itemSessionOperationSaveCompletionOperation(
                        self) {
                    transferOperation.chainOperation(with: completion)
                    operations.append(completion)
                }

                OperationQueue.background.addOperations(
                    operations, waitUntilFinished: synced)
            })],
            waitUntilFinished: synced)
    }

    func timeRangeControllerDidFinishCreatingRanges(
        _ timeRangeController: TimeRangeController, synced: Bool
    ) {
        guard let context = Storage.shared?.createContext else { return }

        OperationQueue.itemSession.addOperations(
            [BlockOperation(block: {
                let updateItemSession = BlockOperation {
                    context.performAndWait {
                        self.itemSession?.isActive = false
                    }
                }
                updateItemSession.addDependency(self.lastSaveOperation)
                let cleanup = BlockOperation {
                    guard let itemSession = self.itemSession else { return }

                    context.performAndWait {
                        if itemSession.playbackRanges?.count == 0 {
                            context.delete(itemSession)
                        }
                    }
                }
                cleanup.addDependency(updateItemSession)
                let saveOperation = SaveContextOperation(context: context)
                saveOperation.addDependency(cleanup)
                saveOperation.completionBlock = {
                    self.finish()
                }

                OperationQueue.background.addOperations(
                    [updateItemSession, cleanup, saveOperation],
                    waitUntilFinished: synced)
            })],
            waitUntilFinished: synced)
    }
}
