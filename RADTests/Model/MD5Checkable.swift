//
//  MD5Checkable.swift
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

import Foundation
import XCTest

protocol MD5Checkable {
    func checkMD5(
        for string: String,
        expectedMD5: String,
        file: StaticString,
        line: UInt)
}

extension MD5Checkable {
    /// Create the MD5 hash value for the string
    /// and compare it with the expected one.
    ///
    /// - Parameters:
    ///   - string: The source string to convert.
    ///   - expectedMD5: The expected MD5.
    func checkMD5(
        for string: String,
        expectedMD5: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if let convertedMD5 = string.md5 {
            XCTAssertEqual(
                expectedMD5.uppercased(),
                convertedMD5.uppercased(),
                "'md5' property could not convert the string into MD5.",
                file: file,
                line: line)
        } else {
            XCTFail("'md5' property could not convert the string into MD5.")
        }
    }
}
