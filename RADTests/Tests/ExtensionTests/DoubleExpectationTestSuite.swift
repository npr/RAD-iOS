//
//  DoubleExpectationTestSuite.swift
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

class DoubleExpectationTestSuite: XCTestCase {
    func testCaseForNonNumericCharacters() {
        let string = "abc"
        let value = Double.from(string: string)
        XCTAssertNil(
            value,
            "'\(string)' should have not been converted into a double value.")

    }

    func testCaseFor_successValue() {
        let string = "123"
        let expected: Double = 123
        let converted = Double.from(string: string)
        XCTAssertNotNil(
            converted,
            "'\(string)' should have been converted into a double value.")
        XCTAssertTrue(
            converted?.isEqual(to: expected) == true,
            "Expected value and converted value are not equal.")
    }
}
