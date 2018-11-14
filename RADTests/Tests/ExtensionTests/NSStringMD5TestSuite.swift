//
//  NSStringMD5TestSuite.swift
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

class NSStringMD5TestSuite: XCTestCase, MD5Checkable {
    func testCaseFor_randomString() {
        checkMD5(
            for: "This string is used to test the conversion into MD5.",
            expectedMD5: "CAC9D9082302D8C988E1DF8144077AA1")
    }

    func testCaseFor_json() {
        guard let url = Bundle.testBundle.url(
            forResource: "MD5_JSON", withExtension: "json") else {
                XCTFail("Resource is not available.")
                return
        }
        do {
            let json = try String(contentsOf: url)
            checkMD5(for: json, expectedMD5: "C8883B8842CCF7AE1A4D98A9BA9F5213")
        } catch {
            XCTFail("Failed to convert data from resource into string due to error: \(error)")
        }
    }
}
