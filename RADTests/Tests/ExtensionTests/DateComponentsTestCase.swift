//
//  DateComponentsTestCase.swift
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

class DateComponentsTestCase: XCTestCase {
    func testMinusOperator() {
        let components = DateComponents(
            year: 1, month: 2, day: 3, hour: 4, minute: 5, second: 6,
            nanosecond: 7)
        let invertedComponents = -components
        XCTOptionalInversedAssertEqual(
            components.year,
            invertedComponents.year,
            "Year components are not equal")
        XCTOptionalInversedAssertEqual(
            components.month,
            invertedComponents.month,
            "Month components are not equal.")
        XCTOptionalInversedAssertEqual(
            components.day,
            invertedComponents.day,
            "Day components are not equal.")
        XCTOptionalInversedAssertEqual(
            components.hour,
            invertedComponents.hour,
            "Hour components are not equal.")
        XCTOptionalInversedAssertEqual(
            components.minute,
            invertedComponents.minute,
            "Minute components are not equal")
        XCTOptionalInversedAssertEqual(
            components.second,
            invertedComponents.second,
            "Second components are not equal.")
        XCTOptionalInversedAssertEqual(
            components.nanosecond,
            invertedComponents.nanosecond,
            "Nanosecond components are not equal.")
    }
}
