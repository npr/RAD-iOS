//
//  RadIDUnlockedTestSuite.swift
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

class RadIDUnlockedTestSuite: AnalyticsTestCase, RADExtractionTestCase {
    func testCaseFor_radIsUnlocked_duringPlayback() {
        let item: AVPlayerItem! = findResource(name: "180Events")
        player.replaceCurrentItem(with: item)

        player.play()

        let fetchExpectation = self.expectation(
            description: "Rad fetch.")

        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(1), execute: {
                guard let md5 = self.extractMD5(from: item) else {
                    XCTFail("Unable to created MD5 from RAD payload.")
                    return
                }
                self.expectUnlockedRad(
                    andFulfill: fetchExpectation, for: md5)
        })

        wait(for: [fetchExpectation], timeout: TimeInterval.seconds(5))
    }

    func testCaseFor_radIsUnlocked_afterPlayback() {
        let item: AVPlayerItem! = findResource(name: "240Events")
        player.replaceCurrentItem(with: item)

        player.play()

        let itemReplacedExpectation = self.expectation(
            description: "Player did replace item.")

        let fetchExpectation = self.expectation(
            description: "Item session fetch.")

        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(2), execute: {
                self.player.pause()
                self.player.replaceCurrentItem(with: nil)
                itemReplacedExpectation.fulfill()

                DispatchQueue.background.asyncAfter(
                    deadline: .now() + .seconds(2), execute: {
                        guard let md5 = self.extractMD5(from: item) else {
                            XCTFail("Unable to create MD5 from RAD payload.")
                            return
                        }
                        self.expectUnlockedRad(
                            andFulfill: fetchExpectation, for: md5)
                })
        })

        wait(
            for: [itemReplacedExpectation, fetchExpectation],
            timeout: TimeInterval.seconds(10))
    }

    func testCaseFor_unavailableResource() {
        guard let context = Storage.shared?.createContext else {
            XCTFail("Resource not available.")
            return
        }

        let lockOperation = LockRadOperation(context: context)
        lockOperation.updateReady(true)
        let failExpectation = self.expectation(description: "")
        lockOperation.completionBlock = { [weak lockOperation] in
            XCTAssertNotNil(
                lockOperation?.finishError,
                "Lock operation should have finished with error.")
            failExpectation.fulfill()
        }

        concurrentQueue.addOperation(lockOperation)

        wait(for: [failExpectation], timeout: TimeInterval.seconds(5))
    }

    // MARK: Private functionality

    private func expectUnlockedRad(
        andFulfill expectation: XCTestExpectation,
        for md5: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let context = Storage.shared?.createContext else {
            XCTFail("Resource not available.")
            return
        }

        let fetchOperation = FetchOperation<Rad>(context: context)
        let md5Predicate = NSPredicate(
            format: "md5 == '\(md5)'", argumentArray: nil)
        let isLockedPredicate = NSPredicate(
            format: "isLocked == false", argumentArray: nil)
        fetchOperation.input = NSCompoundPredicate(
            andPredicateWithSubpredicates: [md5Predicate, isLockedPredicate])
        let inputOperation = ClosureInputOperation<[Rad]> { ids in
            XCTAssert(
                ids.count == 1, "Rad is not unlocked.", file: file, line: line)
            expectation.fulfill()
        }
        fetchOperation.chainOperation(with: inputOperation)

        serialQueue.addOperations(
            [fetchOperation, inputOperation], waitUntilFinished: false)
    }
}
