//
//  OperationIsCancelled.swift
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

class OperationIsCancelled: OperationTestCase {
    func testIsCancelled_notExecuting() {
        var flag = false
        let changeFlagOperation = ClosureOperation {
            flag = true
        }
        changeFlagOperation.cancel()
        concurrentQueue.addOperations(
            [changeFlagOperation], waitUntilFinished: true)
        XCTAssertFalse(flag, "The flag should not have been changed since the operation was cancelled.")
    }
}
