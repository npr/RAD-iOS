//
//  Analytics.swift
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
import AVFoundation

/// The Analytics object which ties the framework components.
@objc public class Analytics: NSObject {
    public typealias BackgroundFetchCompletion =
        (UIBackgroundFetchResult) -> Void

    public var configuration: Configuration {
        return scheduler.configuration
    }
    /// Debug interface for analytics.
    public var debugger: AnalyticsDebuggable {
        return _debugger
    }
    private let _debugger: AnalyticsDebugger
    private var playerObserver: PlayerObserver?
    private let scheduler: NetworkScheduler

    /// Create an analytics object with a custom configuration.
    /// Through configuration allows changing various properties,
    /// such as batch size of events sent to analytics servers provided as
    /// tracking urls from RAD payload embedded in the media files.
    ///
    /// At initization, the analytics object starts sending data
    /// to analytics servers.
    ///
    /// The default configuration is set to:
    /// - *submission time interval*: 1 hour;
    /// - *batch size*: 100 events;
    /// - *expiration time interval*: 14 days;
    /// - *session expiration time interval*: 24 hours;
    /// - *request header fields*: [:] - empty dictionary.
    ///
    /// - Parameter configuration: The configuration object.
    public init(
        configuration: Configuration = Configuration(
            submissionTimeInterval: TimeInterval.hours(1),
            batchSize: 100,
            expirationTimeInterval: DateComponents(day: 14),
            sessionExpirationTimeInterval: TimeInterval.hours(24),
            requestHeaderFields: [:])
    ) {
        Storage.shared?.load()
        _debugger = AnalyticsDebugger()
        scheduler = NetworkScheduler(configuration: configuration)
        super.init()
        startSendingData()
        performSanityCheck()
    }

    /// Starts observing a player until the object is deallocated from memory.
    /// The instance records data starting with the next item.
    /// If the player has only 1 item, the player should be created with no item
    /// and replace the item on player after starting the observation.
    ///
    /// ```
    /// let item = AVPlayerItem(...)
    /// player = AVPlayer(playerItem: nil)
    /// analytics.observePlayer(player)
    /// player.replaceCurrentItem(with: item)
    /// ```
    ///
    /// - Parameter player: The player to be observed.
    public func observePlayer(_ player: AVPlayer) {
        playerObserver = PlayerObserver(
            player: player, configuration: configuration)
        playerObserver?.delegate = _debugger
    }

    /// Starts sending data to analytics servers.
    /// Sending data is started automatically at object creation.
    public func startSendingData() {
        scheduler.startScheduling()
    }

    /// Stops sending data to analytics servers.
    public func stopSendingData() {
        scheduler.endScheduling()
    }

    /// Starts a task of sending data to analytics servers
    /// while the application is in background. Once the task has finished,
    /// calls the completion handler on the main queue.
    ///
    /// - Parameter completion: The completion handler.
    public func performBackgroundFetch(
        completion: @escaping BackgroundFetchCompletion
    ) {
        scheduler.executeDataSent { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // MARK: Private functionality

    private func performSanityCheck() {
        OperationQueue.background.addOperations(
            [ItemSessionDeactivateOperation(), UnlockObjectsOperation()],
            waitUntilFinished: true)
    }
}
