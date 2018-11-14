//
//  AnalyticsTestCase.swift
//  RADTests
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

import XCTest
import AVFoundation
import CoreData
@testable import RAD

class AnalyticsTestCase: OperationTestCase {
    /// The rule which the test case may use to empty the database.
    ///
    /// - none: The database remains the same.
    /// - once: The database is deleted upon calling first test.
    /// - always: The detabase is deleted after each test.
    enum DatabaseCleanupRule {
        case none, once, always
    }

    lazy var player: AVPlayer = {
        return playerClass.init()
    }()
    var playerClass: AVPlayer.Type {
        return MockPlayer.self
    }

    var configuration: Configuration {
        return Configuration.unlimitedTime
    }

    var databaseCleanupRule: DatabaseCleanupRule {
        return .none
    }

    var analytics: Analytics!

    private var databaseWasDeletedOnce = false
    private var databaseName: String {
        return "RADDatabase"
    }

    override func setUp() {
        super.setUp()

        applyDatabaseDeleteRule()

        analytics = Analytics(configuration: configuration)
        analytics.observePlayer(player)
    }

    private func applyDatabaseDeleteRule() {
        switch databaseCleanupRule {
        case .always:
            Storage.shared?.refreshDatabase()
        case .once:
            if !databaseWasDeletedOnce {
                databaseWasDeletedOnce = true
                Storage.shared?.refreshDatabase()
            }
        default:
            break
        }
    }
}
