//
//  ItemSessionInactiveTestSuite.swift
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
@testable import RAD

class ItemSessionInactiveTestSuite: AnalyticsTestCase, RADExtractionTestCase {
    func testCaseFor_itemSessionIsActiveDuringPlayback() {
        guard let url = Bundle.testBundle.url(
            forResource: "RAD_events",
            withExtension: "m4a"
        ) else {
            XCTFail("Resource not available.")
            return
        }

        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)

        player.play()

        let pauseExpectation = self.expectation(
            description: "Player did pause.")

        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(5), execute: {
                self.player.pause()
                pauseExpectation.fulfill()
        })

        let fetchExpectation = self.expectation(
            description: "Item session fetch.")

        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(2), execute: {
                guard let md5 = self.extractMD5(from: item) else {
                    XCTFail("Unable to create MD5 from RAD payload.")
                    return
                }
                self.expectOneFetchedItemSession(
                    andFulfill: fetchExpectation, for: md5)
        })

        wait(
            for: [pauseExpectation, fetchExpectation],
            timeout: TimeInterval.minutes(1))
    }

    func testCaseFor_itemSessionIsInactiveAfterPlayback() {
        guard let url = Bundle.testBundle.url(
            forResource: "1_000Events2TrackingUrls",
            withExtension: "mp3"
        ) else {
                XCTFail("Resource not available.")
                return
        }

        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)

        player.play()

        let itemReplacedExpectation = self.expectation(
            description: "Player did replace item.")

        let fetchExpectation = self.expectation(
            description: "Item session fetch.")

        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(15), execute: {
                self.player.pause()
                self.player.replaceCurrentItem(with: nil)
                itemReplacedExpectation.fulfill()

                DispatchQueue.background.asyncAfter(deadline: .now() + .seconds(2)) {
                    guard let md5 = self.extractMD5(from: item) else {
                        XCTFail("Unable to create MD5 from RAD payload.")
                        return
                    }
                    self.expectInactiveSessions(fulfilling: fetchExpectation, for: md5)
                }
        })

        wait(
            for: [itemReplacedExpectation, fetchExpectation],
            timeout: TimeInterval.minutes(1))
    }

    // MARK: Private functionality

    private func expectOneFetchedItemSession(
        andFulfill expectation: XCTestExpectation, for md5: String
    ) {
        guard let context = Storage.shared?.createContext else {
            XCTFail("Resource not available.")
            return
        }

        let fetchOperation = FetchOperation<ItemSession>(context: context)
        let md5Predicate = NSPredicate(
            format: "sessionId.rad.md5 == '\(md5)'", argumentArray: nil)
        let inactivePredicate = NSPredicate(
            format: "isActive == true", argumentArray: nil)
        fetchOperation.input = NSCompoundPredicate(
            andPredicateWithSubpredicates: [md5Predicate, inactivePredicate])
        let inputOperation = ClosureInputOperation<[ItemSession]> { sessions in
            XCTAssert(sessions.count == 1, "Item session is not active.")
            expectation.fulfill()
        }
        fetchOperation.chainOperation(with: inputOperation)

        serialQueue.addOperations(
            [fetchOperation, inputOperation], waitUntilFinished: false)
    }

    private func expectInactiveSessions(
        fulfilling expectation: XCTestExpectation, for md5: String
    ) {

        guard let context = Storage.shared?.createContext else {
            XCTFail("Resource not available.")
            return
        }

        let fetchOperation = FetchOperation<ItemSession>(context: context)
        let md5Predicate = NSPredicate(
            format: "sessionId.rad.md5 == '\(md5)'", argumentArray: nil)
        let inactivePredicate = NSPredicate(
            format: "isActive == true", argumentArray: nil)
        fetchOperation.input = NSCompoundPredicate(
            andPredicateWithSubpredicates: [md5Predicate, inactivePredicate])
        let inputOperation = ClosureInputOperation<[ItemSession]> { sessions in
            XCTAssert(sessions.count == 0, "No item session should be active.")
            expectation.fulfill()
        }
        fetchOperation.chainOperation(with: inputOperation)

        serialQueue.addOperations(
            [fetchOperation, inputOperation], waitUntilFinished: false)
    }
}
