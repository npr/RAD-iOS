//
//  OutputOperationTestSuite.swift
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

class OutputOperationTestSuite: OperationTestCase {
    func testCaseFor_finishWithOutput() {
        let operation = BooleanOutputOperation()
        let expectation = self.expectation(
            description: "Output operation should have finished with object.")
        let inputOperation = ClosureInputOperation<Bool> { _ in
            expectation.fulfill()
        }
        operation.chainOperation(with: inputOperation)
        concurrentQueue.addOperations(
            [operation, inputOperation], waitUntilFinished: false)
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
    }

    func testCaseFor_finishWithError() {
        let operation = ErrorOutputOperation()
        let inputOperation = ClosureInputOperation<Bool> { _ in }
        operation.chainOperation(with: inputOperation)
        let expectation = self.expectation(
            description: "Output operation should have finished with errror.")
        operation.completionBlock = { [weak operation] in
            guard let strongOperation = operation else { return }
            if strongOperation.finishError != nil {
                expectation.fulfill()
            }
        }
        concurrentQueue.addOperations(
            [operation, inputOperation], waitUntilFinished: true)
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
        XCTAssertTrue(
            inputOperation.isCancelled,
            "Input operation should have been cancelled.")
    }

    func testCaseFor_cancellingOperation() {
        let operation = BooleanOutputOperation()
        let inputOperation = ClosureInputOperation<Bool> { _ in }
        operation.chainOperation(with: inputOperation)
        operation.cancel()
        concurrentQueue.addOperations(
            [operation, inputOperation], waitUntilFinished: true)
        XCTAssertTrue(
            operation.isCancelled,
            "Input operation should have been cancelled.")
        XCTAssertTrue(
            inputOperation.isCancelled,
            "Input operation should have been cancelled.")
    }
}
