//
//  AnalyticsDebuggable.swift
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

/// An interface which may be inspected to access data for debug purposes.
public protocol AnalyticsDebuggable {
    typealias Completion = ([Object]) -> Void
    typealias ExtractCompletion = (String) -> Void

    /// Retrieve objects for a specific table.
    ///
    /// - Parameters:
    ///   - table: The table to retrieve.
    ///   - completion: The completion called after finishing retrieval
    ///   of object for specified table.
    func objects(for type: ObjectType, completion: @escaping Completion)

    /// Add an observer to lister for generated objects.
    ///
    /// - Parameter observer: The observer.
    func addListeningObserver(_ observer: ListeningObserver)
    /// Removes an observer. It is not required to call the remove.
    ///
    /// - Parameter observer: The registered observer.
    func removeListeningObserver(_ observer: ListeningObserver)

    /// Extract RAD payload from an AVAsset. The RAD payload is formatted
    /// to be ready for displaying.
    /// The completion handler is called on main queue.
    ///
    /// - Parameters:
    ///   - asset: The resource.
    ///   - completion: The completion handler.
    func extractRADPayload(
        from asset: AVAsset, completion: @escaping ExtractCompletion)
}
