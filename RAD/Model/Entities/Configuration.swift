//
//  Configuration.swift
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

@objc public class Configuration: NSObject {
    /// The time interval upon which events are sent to analytics server.
    public let submissionTimeInterval: TimeInterval

    /// The maximum number of events to be sent in a request.
    public let batchSize: UInt

    /// The time after which stored local events will be deleted
    /// without sending them to server.
    public let expirationTimeInterval: DateComponents

    /// The time after which the session expires.
    public let sessionExpirationTimeInterval: TimeInterval

    /// A dictionary which will be set as header fields to each
    /// request created to each tracking url.
    public let requestHeaderFields: [String: String]

    @objc public init(
        submissionTimeInterval: TimeInterval,
        batchSize: UInt,
        expirationTimeInterval: DateComponents,
        sessionExpirationTimeInterval: TimeInterval,
        requestHeaderFields: [String: String]
    ) {
        self.submissionTimeInterval = submissionTimeInterval
        self.batchSize = batchSize
        self.expirationTimeInterval = expirationTimeInterval
        self.sessionExpirationTimeInterval = sessionExpirationTimeInterval
        self.requestHeaderFields = requestHeaderFields
        super.init()
    }
}
