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
@testable import RAD

class AnalyticsTestSuite: AnalyticsTestCase {
    func testBackgroundFetch() {
        analytics.stopSendingData()
        analytics.startSendingData()

        guard let url = Bundle.testBundle.url(
            forResource: "1_000Events",
            withExtension: "mp3"
        ) else {
            XCTFail("Resource is not available.")
            return
        }

        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)

        let expectation = self.expectation(
            description: "Wait for background fetch.")

        self.player.play()

        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(5), execute: {
                self.player.replaceCurrentItem(with: nil)
                DispatchQueue.background.asyncAfter(
                    deadline: .now() + .seconds(2), execute: {
                        self.analytics.performBackgroundFetch { _ in
                            expectation.fulfill()
                        }
                })
        })

        wait(for: [expectation], timeout: TimeInterval.seconds(20))
    }
}
