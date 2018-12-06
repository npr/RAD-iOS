//
//  AnalyticsDebuggerExtractPayloadTestCase.swift
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

class AnalyticsDebuggerExtractPayloadTestCase: AnalyticsTestCase, MD5Checkable {
    func testPayloadExtraction() {
        let item: AVPlayerItem! = findResource(name: "50Events")

        let payloadExpectation = self.expectation(
            description: "Payload check.")
        analytics.debugger.extractRADPayload(
            from: item.asset,
            completion: { payload in
                self.checkMD5(
                    for: payload,
                    expectedMD5: "4F2249C973480A1968E61F523A2C2F01")
                payloadExpectation.fulfill()
        })
        wait(for: [payloadExpectation], timeout: TimeInterval.seconds(30))
    }

    func testRangeCreation() {
        let item: AVPlayerItem! = findResource(name: "1_000Events")
        let expectation = RangeExpectation(
            description: "Time range was created.")

        DispatchQueue.main.asyncAfter(
            deadline: .now() + .seconds(1), execute: {
                self.analytics.debugger.addListeningObserver(expectation)
                self.play(item: item, for: .seconds(20))
        })

        wait(for: [expectation], timeout: TimeInterval.minutes(1))
    }

    func testListeningRemoval() {
        let item: AVPlayerItem! = findResource(name: "1_000Events")
        let expectation = RangeExpectation(
            description: "Time range was created.")
        expectation.assertForOverFulfill = true
        player.replaceCurrentItem(with: item)

        DispatchQueue.main.asyncAfter(
            deadline: .now() + .seconds(1), execute: {
                self.analytics.debugger.addListeningObserver(expectation)
                self.player.play()
        })

        let waitExpectation = self.expectation(description: "Second pause.")

        DispatchQueue.concurrent.asyncAfter(
            deadline: .now() + .seconds(5), execute: {
                self.player.pause()

                DispatchQueue.concurrent.asyncAfter(
                    deadline: .now() + .seconds(5),
                    execute: {
                        self.analytics.debugger.removeListeningObserver(
                            expectation)
                        self.player.play()
                        DispatchQueue.concurrent.asyncAfter(
                            deadline: .now() + .seconds(5),
                            execute: {
                                self.player.pause()
                                waitExpectation.fulfill()
                        })
                })
        })

        wait(
            for: [expectation, waitExpectation],
            timeout: TimeInterval.minutes(1))
    }
}

private class RangeExpectation: XCTestExpectation, ListeningObserver {
    func didGenerateListeningRanges(_ ranges: [Object]) {
        fulfill()
    }
}
