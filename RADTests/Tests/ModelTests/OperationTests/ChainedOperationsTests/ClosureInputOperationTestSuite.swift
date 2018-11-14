//
//  ClosureInputOperationTestSuite.swift
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

class ClosureInputOperationTestSuite: OperationTestCase {
    func testClosureIsCalled() {
        var flag = false
        let expectation = self.expectation(
            description: "Closure operation is not calling the closure.")
        let operation = ClosureInputOperation<Bool> { value in
            flag = value
            expectation.fulfill()
        }
        operation.input = true
        concurrentQueue.addOperation(operation)
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
        XCTAssertTrue(flag, "Closure was not called")
    }

    func testInput_notAvailable() {
        var flag = true
        let expectation = self.expectation(description: "Operation did finish.")
        let operation = ClosureInputOperation<Bool> { _ in
            flag = false
        }
        operation.completionBlock = {
            expectation.fulfill()
        }
        operation.updateReady(true)
        concurrentQueue.addOperation(operation)
        wait(for: [expectation], timeout: TimeInterval.seconds(1))
        XCTAssertTrue(flag, "Closure operation should not call the closure.")
    }
}
