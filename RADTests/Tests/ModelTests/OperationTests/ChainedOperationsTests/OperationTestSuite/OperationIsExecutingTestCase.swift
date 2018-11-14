//
//  OperationIsExecutingTestCase.swift
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
import Foundation
@testable import RAD

class OperationIsExecutingTestCase: OperationTestCase {
    func testIsExecuting() {
        let operation = PlainOperation()

        let isNotExecutingExpectation = KVOExpectation(
            description: "'isExecuting' should be false",
            object: operation,
            keyPath: \RAD.Operation.isExecuting,
            expectedValue: false)
        let isExecutingExpectation = KVOExpectation(
            description: "'isExecuting' should be true",
            object: operation,
            keyPath: \RAD.Operation.isExecuting,
            expectedValue: true)

        XCTAssertFalse(
            operation.isExecuting,
            "Operation should be executing before is added in the queue.")
        concurrentQueue.addOperation(operation)
        wait(
            for: [isExecutingExpectation, isNotExecutingExpectation],
            timeout: TimeInterval.milliseconds(100),
            enforceOrder: true)
    }
}
