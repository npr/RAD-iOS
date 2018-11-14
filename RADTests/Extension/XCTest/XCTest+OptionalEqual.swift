//
//  XCTest+OptionalEqual.swift
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

/// Test if two optional objects are equal.
///
/// - Parameters:
///   - lhs: The first object.
///   - rhs: The second object.
///   - message: The message to print if test fails.
func XCTOptionalAssertEqual<T: Equatable>(
    _ lhs: T?,
    _ rhs: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    switch (lhs, rhs) {
    case (nil, _):
        XCTFail(chooseMessage(
            message, "Left hand side is not available. Therefore are not equal."
            )
        )
    case (_, nil):
        XCTFail(chooseMessage(
            message,
            "Right hand side is not available. Therefore are not equal."))
    case (let left?, let right?):
        if left != right {
            XCTFail(chooseMessage(message, "Left and right are not equal."))
        }
    }
}

/// Test if first object is equal with inverted second value.
///
/// - Parameters:
///   - lhs: The object to test.
///   - rhs: The object which is inverted.
///   - message: The message to print if test fails.
func XCTOptionalInversedAssertEqual<T: Equatable & Inversable>(
    _ lhs: T?,
    _ rhs: T?,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    switch (lhs, rhs) {
    case (nil, _):
        XCTFail(chooseMessage(
            message,
            "Left hand side is not available. Therefore are not equal."),
                file: file,
                line: line
        )
    case (_, nil):
        XCTFail(chooseMessage(
            message,
            "Right hand side is not available. Therefore are not equal."),
                file: file,
                line: line
        )
    case (let left?, let right?):
        XCTAssertEqual(
            left,
            -right,
            chooseMessage(message, "Left and right are not equal."),
            file: file,
            line: line
        )
    default:
        XCTFail("Unexpected case found while comparison optionals.")
    }
}
