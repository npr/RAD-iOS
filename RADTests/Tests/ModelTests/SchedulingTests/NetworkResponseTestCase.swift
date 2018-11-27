//
//  NetworkResponseTestCase.swift
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
import OHHTTPStubs
@testable import RAD

class NetworkResponseTestCase: AnalyticsTestCase {
    override var configuration: Configuration {
        return Configuration(
            submissionTimeInterval: .seconds(15),
            batchSize: 10,
            expirationTimeInterval: DateComponents(day: 1),
            sessionExpirationTimeInterval: .hours(24),
            requestHeaderFields: [:])
    }

    func performPlayback() {
        let item = findResource(name: "1_000Events")

        play(item: item, for: .seconds(3))
    }

    func stubRequests(withStatusCode statusCode: Int32) {
        OHHTTPStubs.stubRequests(passingTest: { _ in
            return true
        }, withStubResponse: { request -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(
                jsonObject: [:],
                statusCode: statusCode, headers: nil)
        })
        wait(for: configuration.submissionTimeInterval + 5)
    }

    func checkEventsInDatabase(
        isEmpty: Bool, file: StaticString = #file, line: UInt = #line
    ) {
        let fetchExpectation = self.expectation(
            description: "Fetch expectation.")
        analytics.debugger.objects(for: .event, completion: { events in
            let noEvents = events.count == 0
            XCTAssert(
                noEvents == isEmpty,
                "Events check failed",
                file: file,
                line: line)
            fetchExpectation.fulfill()
        })

        wait(for: [fetchExpectation], timeout: .seconds(10))
    }
}
