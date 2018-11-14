//
//  DispatchQueueTestCase.swift
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

class DispatchQueueTestCase: XCTestCase {
    private let queue = DispatchQueue(
        label: "DispatchQueueTestCase", attributes: [.concurrent])

    func testSyncExecution() {
        let value = "Value"
        var valueToSet: String?
        queue.execute(block: {
            valueToSet = value
        }, async: false)
        XCTOptionalAssertEqual(
            value,
            valueToSet,
            "Execute function is not running correctly for sync.")
    }

    func testAsyncExecution() {
        let value = "Value"
        var valueToSet: String?
        let expectation = XCTestExpectation(
            description: "Variable set expectation.")
        queue.execute(block: {
            valueToSet = value
            expectation.fulfill()
        }, async: true)
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
        XCTOptionalAssertEqual(
            value,
            valueToSet,
            "Execute function is not running correctly for async.")
    }
}
