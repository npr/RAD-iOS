//
//  TimeRangeControllerEndOfFileTestCase.swift
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

class TimeRangeControllerEndOfFileTestCase: PlayerTestCase,
RangeCreationExpectationBuilder {
    override var resourceName: String {
        return "small_audio_file"
    }
    override var resourceExtension: String {
        return "m4a"
    }

    func testCaseFor_rangeCreation_reachingEndOfFile() {
        guard let item = item else {
            XCTFail("Current item is not set on player.")
            return
        }
        let playToEndExpectation = ItemDidPlayToEndExpectation(
            item: item, description: "Item did play to end.")
        let rangeCreationExpectation = buildRangeCreationExpectation()

        let duration = item.asset.duration.seconds
        let timeout = duration + TimeInterval.seconds(10)

        player.play()

        wait(
            for: [playToEndExpectation, rangeCreationExpectation],
            timeout: timeout
        )

        player.replaceCurrentItem(with: nil)
    }
}
