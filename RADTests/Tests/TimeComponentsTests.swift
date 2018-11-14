//
//  TimeComponentsTests.swift
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
@testable import RAD

class TimeComponentsTests: XCTestCase {
    func testTimeIntervalSuccess() {
        let components = TimeComponents(hours: 1, minutes: 25, seconds: 0.5)
        XCTAssert(components.timeInterval.equals(to: 5100.5),
                  "Time interval is not computed corretly.")
    }

    func testTimeIntervalFailure() {
        let components = TimeComponents(hours: 2, minutes: 30, seconds: 0)
        XCTAssertFalse(components.timeInterval.equals(to: 5100),
                       "Time interval is not computed corretly.")
    }

    func testDefaultConstructor() {
        let components = TimeComponents(hours: 1, minutes: 25, seconds: 0.5)
        XCTAssert(components.hours.value.equals(to: 1),
                  "Hours property is not set.")
        XCTAssert(components.minutes.value.equals(to: 25),
                  "Minutes property is not set.")
        XCTAssert(components.seconds.value.equals(to: 0.5),
                  "Seconds property is not set.")
    }

    func testTimeIntervalConstructSuccess() {
        let components = TimeComponents(timeInterval: 6600)
        XCTAssert(components?.hours.value.equals(to: 1) == true,
                  "Hours component is not computed correctly.")
        XCTAssert(components?.minutes.value.equals(to: 50) == true,
                  "Minutes component is not computed correctly.")
        XCTAssert(components?.seconds.value.equals(to: 0) == true,
                  "Seconds component is not computed correctly.")
    }

    func testTimeIntervalConstructFailure() {
        let components = TimeComponents(timeInterval: 7500)
        XCTAssertFalse(components?.hours.value.equals(to: 1) == true,
                  "Hours component is not computed correctly.")
        XCTAssert(components?.minutes.value.equals(to: 5) == true,
                  "Minutes component is not computed correctly.")
    }

    func testStringConstructorSuccess() {
        let components = TimeComponents(string: "01:15:42", componentsSeparator: ":")
        XCTAssertNotNil(components)
        XCTAssert(components?.hours.value.equals(to: 1) == true,
                  "Hours component is not computed correctly.")
        XCTAssert(components?.minutes.value.equals(to: 15) == true,
                  "Minutes component is not computed correctly.")
        XCTAssert(components?.seconds.value.equals(to: 42) == true,
                  "Seconds component is not computed correctly.")
    }

    func testStringConstructorSuccess2() {
        let components = TimeComponents(string: "1;1;2", componentsSeparator: ";")
        XCTAssert(components?.hours.value.equals(to: 1) == true,
                  "Hours component is not computed correctly.")
        XCTAssert(components?.minutes.value.equals(to: 1) == true,
                  "Minutes component is not computed correctly.")
        XCTAssert(components?.seconds.value.equals(to: 2) == true,
                  "Seconds component is not computed correctly.")
    }

    func testStringConstructorSuccess3() {
        let components = TimeComponents(string: "2:11:03.123", componentsSeparator: ":")
        XCTAssertNotNil(components)
        XCTAssert(components?.hours.value.equals(to: 2) == true,
                  "Hours component is not computed correctly.")
        XCTAssert(components?.minutes.value.equals(to: 11) == true,
                  "Minutes component is not computed correctly.")
        XCTAssert(components?.seconds.value.equals(to: 3.123) == true,
                  "Seconds component is not computed correctly.")
    }
}
