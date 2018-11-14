//
//  OperationIsReadyTestCase.swift
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

class OperationIsReadyTestCase: XCTestCase {
    func testIsReady_byDefault() {
        let operation = StandByOperation()
        XCTAssertFalse(
            operation.isReady,
            "StandByOperation should be not be ready by default.")
    }

    func testIsReady_getsUpdated() {
        let operation = StandByOperation()
        let expectation = XCTKVOExpectation(
            keyPath: "isReady", object: operation, expectedValue: true)
        operation.updateReady(true)
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
    }

    func testIsReady_falseHavingDependencies() {
        let operation = RAD.Operation()
        let dependentOperation = RAD.Operation()
        operation.addDependency(dependentOperation)

        XCTAssertFalse(
            operation.isReady,
            "Operation should not be ready while having dependencies.")
    }
}
