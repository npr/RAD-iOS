//
//  SimpleTestCaseFullScheduling.swift
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
import OHHTTPStubs

class SimpleTestCaseFullScheduling: AnalyticsTestCase {
    override var configuration: Configuration {
        return Configuration(
            submissionTimeInterval: TimeInterval.seconds(30),
            batchSize: 10,
            expirationTimeInterval: DateComponents(day: 14),
            sessionExpirationTimeInterval: TimeInterval.hours(24),
            requestHeaderFields: [:])
    }

    func testScheduling() {
        guard let url = Bundle.testBundle.url(
            forResource: "50Events2TrackingUrls", withExtension: "mp3"
        ) else {
            XCTFail("Resource is not available.")
            return
        }

        OHHTTPStubs.stubRequests(passingTest: { request -> Bool in
            return request.url?.absoluteString == "https://www.npr.org"
        }, withStubResponse: { _ -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(
                jsonObject: [:], statusCode: 200, headers: nil)
        })
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)

        player.play()

        let pauseExpectation = self.expectation(
            description: "Player did pause.")

        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(15), execute: {
                self.player.pause()
                pauseExpectation.fulfill()
        })

        let waitExpectation = self.expectation(description: "Waiting.")

        DispatchQueue.background.asyncAfter(deadline: .now() + .seconds(40)) {
            waitExpectation.fulfill()
        }

        wait(
            for: [pauseExpectation, waitExpectation],
            timeout: TimeInterval.minutes(1))
    }
}
