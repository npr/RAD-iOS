//
//  TimeIntervalTestSuite.swift
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

class TimeIntervalTestSuite: XCTestCase {
    func testCaseFor_milliseconds() {
        let expected = 0.015
        let computed = TimeInterval.milliseconds(15)
        XCTAssertEqual(
            expected,
            computed,
            "TimeInterval's milliseconds is not computing the value correcly.")
    }

    func testCaseFor_floatingPointMilliseconds() {
        let expected = 0.0005
        let computed = TimeInterval.milliseconds(0.5)
        XCTAssertEqual(
            expected,
            computed,
            "TimeInterval's milliseconds is not computing the value correcly.")
    }

    func testCaseFor_minutes() {
        let expected: Double = 180 // 3 minutes
        let computed = TimeInterval.minutes(3)
        XCTAssertEqual(
            expected,
            computed,
            "TimeInterval's minutes is not computing the value correcly.")
    }

    func testCaseFor_floatingPointMinutes() {
        let expected: Double = 210 // 3 minutes and 30 seconds
        let computed = TimeInterval.minutes(3.5)
        XCTAssertEqual(
            expected,
            computed,
            "TimeInterval's minutes is not computing the value correcly.")
    }

    func testCaseFor_hours() {
        let expected: Double = 7_200
        let computed = TimeInterval.hours(2)
        XCTAssertEqual(
            expected,
            computed,
            "TimeInterval's hours is not computing the value correcly.")
    }

    func testCaseFor_floatingPointHours() {
        let expected: Double = 9_000
        let computed = TimeInterval.hours(2.5)
        XCTAssertEqual(
            expected,
            computed,
            "TimeInterval's hours is not computing the value correcly.")
    }
}
