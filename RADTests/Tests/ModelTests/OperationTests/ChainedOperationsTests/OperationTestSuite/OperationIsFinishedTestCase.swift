//
//  OperationIsFinishedTestCase.swift
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

class OperationIsFinishedTestCase: OperationTestCase {
    func testIsFinished() {
        let operation = PlainOperation()
        let isFinishedExpectation = XCTKVOExpectation(
            keyPath: RAD.Operation.isFinishedKey,
            object: operation,
            expectedValue: true)

        XCTAssertFalse(
            operation.isFinished,
            "Operation should not be finished before is added on the queue.")
        concurrentQueue.addOperation(operation)
        wait(
            for: [isFinishedExpectation],
            timeout: TimeInterval.milliseconds(100))
    }
}
