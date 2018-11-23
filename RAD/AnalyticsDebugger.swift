//
//  AnalyticsDebugger.swift
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

final class AnalyticsDebugger: AnalyticsDebuggable, PlayerObservationDelegate {
    private var observersContainer = WeakReferenceContainer<ListeningObserver>()
    private var fetcher: DatabaseFetcher?

    init() {
        guard let mainContext = Storage.shared?.mainQueueContext else {
            return
        }
        guard let backgroundContext = Storage.shared?.backgroundQueueContext
        else { return }
        fetcher = DatabaseFetcher(
            mainContext: mainContext, backgroundContext: backgroundContext)
    }

    /// Fetche objects from internal storage for specified type.
    ///
    /// - Parameters:
    ///   - type: The type of objects to fetch.
    ///   - completion: The handler called upon finishing the retrieval.
    func objects(for type: ObjectType, completion: @escaping Completion) {
        guard let fetcher = fetcher else { return }
        fetcher.fetchObjects(for: type, completion: completion)
    }

    /// Register to listening events.
    ///
    /// - Parameter observer: The observer to register.
    func addListeningObserver(_ observer: ListeningObserver) {
        observersContainer.append(observer)
    }

    /// Unregister from observing listening events.
    ///
    /// - Parameter observer: The observer be remove.
    func removeListeningObserver(_ observer: ListeningObserver) {
        observersContainer.remove(observer)
    }

    /// Register to observe network calls.
    ///
    /// - Parameter observer: The observer to register.
    func addNetworkObserver(_ observer: NetworkObserver) {
        NetworkService.shared.addNetworkObserver(observer)
    }

    /// Unregister from observing network calls.
    ///
    /// - Parameter observer: The observer to remove.
    func removeNetworkObserver(_ observer: NetworkObserver) {
        NetworkService.shared.removeNetworkObserver(observer)
    }

    func extractRADPayload(
        from asset: AVAsset,
        completion: @escaping ExtractCompletion
    ) {
        let parseOperation = ParseRADPayloadOperation(asset: asset)
        let parseJson = ParseJSONOperation<JSONDictionary>()
        parseOperation.chainOperation(with: parseJson)
        let prettyJson = PrettyJSONOperation<JSONDictionary>()
        parseJson.chainOperation(with: prettyJson)
        let completion = ClosureInputOperation<String>(closure: completion)
        prettyJson.chainOperation(with: completion)

        OperationQueue.background.addOperations(
            [parseOperation, parseJson, prettyJson],
            waitUntilFinished: false)
        OperationQueue.main.addOperation(completion)
    }

    // MARK: PlayerObservationDelegate

    func playerDidCreateRanges(with ids: [NSManagedObjectID]) {
        fetcher?.fetchObjects(with: ids, completion: { objects in
            self.observersContainer.forEach({ observer in
                observer?.didGenerateListeningRanges(objects)
            })
        })
    }
}
