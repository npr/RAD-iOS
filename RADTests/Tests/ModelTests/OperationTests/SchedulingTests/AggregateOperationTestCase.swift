//
//  AggregateOperationTestCase.swift
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

class AggregateOperationTestCase: OperationTestCase {
    func testFailedResult() {
        let operation = AggregateOperation()
        operation.add(.failed)
        let expectation = self.expectation(
            description: "Unexpected output result.")
        let input = ClosureInputOperation<UIBackgroundFetchResult> { result in
            if result == .failed {
                expectation.fulfill()
            }
        }
        operation.chainOperation(with: input)
        concurrentQueue.addOperations(
            [operation, input], waitUntilFinished: false)
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
    }

    func testDefaultResult() {
        let operation = AggregateOperation()
        let expectation = self.expectation(
            description: "Unexpected output result.")
        let input = ClosureInputOperation<UIBackgroundFetchResult> { result in
            if result == .noData {
                expectation.fulfill()
            }
        }
        operation.chainOperation(with: input)
        concurrentQueue.addOperations(
            [operation, input], waitUntilFinished: false)
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
    }
}
