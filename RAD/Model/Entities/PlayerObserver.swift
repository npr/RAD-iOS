//
//  PlayerObserver.swift
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

protocol PlayerObservationDelegate: AnyObject {
    /// Delegate function which is called upon creation of ranges.
    ///
    /// - Parameter ids: The NSMananagedObjectID objects which were saved in
    /// database.
    func playerDidCreateRanges(with ids: [NSManagedObjectID])
}

class PlayerObserver: ItemSessionOperationDelegate {
    typealias ItemChangeCompletionClosure = () -> Void
    weak var delegate: PlayerObservationDelegate?

    private var currentItemObservation: Any?
    private let player: AVPlayer
    private let configuration: Configuration

    private var itemChangedCompletion: ItemChangeCompletionClosure?

    init(player: AVPlayer, configuration: Configuration) {
        self.player = player
        self.configuration = configuration

        currentItemObservation = player.observe(
            \.currentItem,
            changeHandler: { [weak self] (_, _) in
                self?.currentItemDidChange()
        })
    }

    // MARK: Private observers

    private func currentItemDidChange() {
        guard let item = player.currentItem else {
            return
        }

        let operation = ItemSessionOperation(
            asset: item.asset, player: player, configuration: configuration)
        operation.delegate = self
        OperationQueue.playerSessions.addOperation(operation)
    }

    // MARK: ItemSessionOperationDelegate

    func itemSessionOperationSaveCompletionOperation(
        _ itemSessionOperation: ItemSessionOperation
    ) -> InputOperation<[NSManagedObjectID]> {
        return ClosureInputOperation<[NSManagedObjectID]>(
            closure: { objectIds in
                self.delegate?.playerDidCreateRanges(with: objectIds)
        })
    }
}
