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
            submissionTimeInterval: TimeInterval.seconds(15),
            batchSize: 10,
            expirationTimeInterval: DateComponents(day: 14),
            sessionExpirationTimeInterval: TimeInterval.hours(24),
            requestHeaderFields: [:])
    }

    func testScheduling() {
        let item: AVPlayerItem! = findResource(name: "50Events")

        OHHTTPStubs.stubRequests(passingTest: { request -> Bool in
            return request.url?.absoluteString == "https://www.npr.org"
        }, withStubResponse: { _ -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(
                jsonObject: [:], statusCode: 200, headers: nil)
        })

        play(item: item, for: .seconds(4))
        let waitExpectation = self.expectation(description: "Waiting.")

        DispatchQueue.concurrent.asyncAfter(deadline: .now() + .seconds(20)) {
            waitExpectation.fulfill()
        }

        wait(for: [waitExpectation], timeout: .seconds(30))

        let fetchExpectation = self.expectation(
            description: "Fetch expectation.")
        analytics.debugger.objects(for: .event, completion: { events in
            XCTAssert(events.count == 0, "")
            fetchExpectation.fulfill()
        })
        wait(for: [fetchExpectation], timeout: .seconds(10))
    }
}
