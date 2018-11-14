//
//  FoundationOperationDependencyTestCase.swift
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

class FoundationOperationDependencyTestCase: OperationTestCase {
    func testForNilOperation() {
        let first = 1
        let second = 2
        var objects: [Int] = []
        var initialNilOperation: Foundation.Operation?

        let expectation = XCTestExpectation(description: "Objects are set.")
        expectation.expectedFulfillmentCount = 2

        let other = BlockOperation {
            objects.append(first)
            expectation.fulfill()
        }
        other.addDependency(initialNilOperation)
        initialNilOperation = BlockOperation {
            objects.append(second)
            expectation.fulfill()
        }
        serialQueue.addOperation(other)
        if let operation = initialNilOperation {
            serialQueue.addOperation(operation)
        }
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
        XCTOptionalAssertEqual(
            objects.first,
            first,
            "First object is not the correct one.")
        XCTOptionalAssertEqual(
            objects.last,
            second,
            "Second object is not the correct one.")
    }

    func testForSomeOptionalOperation() {
        let first = 1
        let second = 2
        var objects: [Int] = []

        let expectation = XCTestExpectation(description: "Objects are set.")
        expectation.expectedFulfillmentCount = 2

        let initialOperation: Foundation.Operation? = BlockOperation {
            objects.append(first)
            expectation.fulfill()
        }

        let other = BlockOperation {
            objects.append(second)
            expectation.fulfill()
        }
        other.addDependency(initialOperation)

        concurrentQueue.addOperation(other)
        if let operation = initialOperation {
            concurrentQueue.addOperation(operation)
        }
        wait(for: [expectation], timeout: TimeInterval.milliseconds(200))
        XCTOptionalAssertEqual(
            objects.first,
            first,
            "First object is not the correct one.")
        XCTOptionalAssertEqual(
            objects.last,
            second,
            "Second object is not the correct one.")
    }
}
