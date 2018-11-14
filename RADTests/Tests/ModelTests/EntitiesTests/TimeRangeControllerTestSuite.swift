//
//  TimeRangeControllerTestSuite.swift
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

class TimeRangeControllerTestSuite: PlayerTestCase,
RangeCreationExpectationBuilder {
    func testCaseFor_rangeCreation_onPause() {
        XCTAssertNotNil(
            player.currentItem, "Current item is not set on player.")

        player.play()
        let expectation = self.expectation(
            description: "Player did pause.")
        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(10),
            execute: {
                self.player.pause()
                expectation.fulfill()
        })

        let rangeCreationExpectation = buildRangeCreationExpectation()

        wait(
            for: [expectation, rangeCreationExpectation],
            timeout: TimeInterval.seconds(12)
        )
    }

    func testCaseFor_rangeCreation_onSeek() {
        player.play()

        let seekExpectation = self.expectation(
            description: "Player did seek.")

        let rangeCreationExpectation = buildRangeCreationExpectation()
        rangeCreationExpectation.expectedFulfillmentCount = 2

        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(2),
            execute: {
                let time = CMTime(
                    seconds: 10,
                    preferredTimescale: CMTime.TimeScale.podcast)
                self.player.seek(to: time)
                seekExpectation.fulfill()
        })

        DispatchQueue.background.asyncAfter(deadline: .now() + 5.0) {
            self.player.pause()
        }

        wait(
            for: [seekExpectation, rangeCreationExpectation],
            timeout: TimeInterval.seconds(10)
        )
    }
}
