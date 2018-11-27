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
import OHHTTPStubs
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

    var reportingUrls: [String] {
        return ["https://www.npr.org"]
    }

    var checkUrlClosure: OHHTTPStubsTestBlock {
        return { request in
            guard let url = request.url?.absoluteString else { return false }
            return self.reportingUrls.firstIndex(of: url) != nil
        }
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

    override func tearDown() {
        super.tearDown()

        wait(for: .seconds(5))
    }

    func findResource(
        name: String,
        extension: String = "mp3",
        file: StaticString = #file,
        line: UInt = #line
    ) -> AVPlayerItem! {
        guard let url = Bundle.testBundle.url(
            forResource: name, withExtension: `extension`
        ) else {
            XCTFail("Resource is not available", file: file, line: line)
            return nil
        }
        return AVPlayerItem(url: url)
    }

    func play(
        item: AVPlayerItem?,
        for time: TimeInterval,
        shouldWait: Bool = true
    ) {
        player.replaceCurrentItem(with: item)
        player.play()

        var expectation: XCTestExpectation?
        if shouldWait {
            expectation = self.expectation(description: "Play expectation.")
        }

        DispatchQueue.concurrent.asyncAfter(
            deadline: .now() + .seconds(time), execute: {
                self.player.pause()
                self.player.replaceCurrentItem(with: nil)
                expectation?.fulfill()
        })

        if shouldWait, let expectation = expectation {
            wait(for: [expectation], timeout: .seconds(time * 2))
        }
    }

    // MARK: Private functionality

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
