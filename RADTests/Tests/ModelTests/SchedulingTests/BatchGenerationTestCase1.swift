//
//  BatchGenerationTestCase1.swift
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

class BatchGenerationTestCase1: AnalyticsTestCase, RADExtractionTestCase {
    override var databaseCleanupRule: DatabaseCleanupRule {
        return .once
    }

    override var configuration: Configuration {
        return Configuration(
            submissionTimeInterval: .seconds(10),
            batchSize: 5,
            expirationTimeInterval: DateComponents(day: 1),
            sessionExpirationTimeInterval: .hours(24),
            requestHeaderFields: [:])
    }

    func testEventsBatching() {
        let item: AVPlayerItem! = findResource(name: "360Events")

        let requestExpectation = self.expectation(
            description: "Request did fail.")
        requestExpectation.assertForOverFulfill = false

        OHHTTPStubs.stubRequests(
            passingTest: checkUrlClosure,
            withStubResponse: { request -> OHHTTPStubsResponse in
                self.check(request: request)
                requestExpectation.fulfill()
                return OHHTTPStubsResponse(
                    jsonObject: [:], statusCode: 200, headers: nil)
        })

        play(item: item, for: .seconds(3.2))

        wait(for: [requestExpectation], timeout: .seconds(30))
    }

    private func check(request: URLRequest) {
        let eventsCount = numberOfEvents(in: request)
        XCTAssert(
            eventsCount == configuration.batchSize,
            "Request does not have correct number of events.")
    }

    private func numberOfEvents(in request: URLRequest) -> UInt {
        guard let data = request.ohhttpStubs_httpBody else {
            XCTFail("Request does not contain body.")
            return UInt.max
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let dictionary = json as? JSONDictionary else {
                XCTFail("Failed to convert json into dictionary.")
                return UInt.max
            }
            guard let sessions = dictionary[Server.JSONProperty.audioSessions] as? JSONArray else {
                XCTFail("Sessions are not available in http request body.")
                return UInt.max
            }
            return sessions.reduce(0, { current, session in
                guard let events = session[RadMetadata.JSONProperty.events] as? JSONArray else {
                    XCTFail("Current session does not have events attached.")
                    return 0
                }
                return UInt(events.count)
            })
        } catch {
            XCTFail("JSON decoding failed with error: \(error)")
            return UInt.max
        }
    }
}
