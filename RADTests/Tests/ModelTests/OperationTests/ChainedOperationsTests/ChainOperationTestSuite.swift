//
//  ChainOperationTestSuite.swift
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

class ChainOperationTestSuite: OperationTestCase {
    func testCaseFor_finishWithOutput() {
        let outputOperation = BooleanOutputOperation()
        let chainOperation = ReverseBooleanOperation()
        outputOperation.chainOperation(with: chainOperation)
        let expectation = self.expectation(
            description: "Chain operation should have finished with object.")
        let input = ClosureInputOperation<Bool> { _ in
            expectation.fulfill()
        }
        chainOperation.chainOperation(with: input)
        serialQueue.addOperations(
            [outputOperation, chainOperation, input], waitUntilFinished: false)
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
    }

    func testCaseFor_cancellingOperations() {
        let outputOperation = BooleanOutputOperation()
        let chainOperation = ReverseBooleanOperation()
        outputOperation.chainOperation(with: chainOperation)
        let inputOperation = ClosureInputOperation<Bool> { _ in }
        chainOperation.chainOperation(with: inputOperation)
        outputOperation.cancel()

        serialQueue.addOperations(
            [outputOperation, chainOperation, inputOperation],
            waitUntilFinished: true)
        XCTAssertTrue(
            outputOperation.isCancelled,
            "Input operation should have been cancelled.")
        XCTAssertTrue(
            chainOperation.isCancelled,
            "Input operation should have been cancelled.")
        XCTAssertTrue(
            inputOperation.isCancelled,
            "Input operation should have been cancelled.")
    }
}
