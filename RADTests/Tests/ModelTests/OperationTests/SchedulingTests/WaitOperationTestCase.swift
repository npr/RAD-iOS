//
//  WaitOperationTestCase.swift
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

class WaitOperationTestCase: OperationTestCase {
    func testforWaiting() {
        let waitOperation = WaitOperation()
        let waitTime = TimeInterval.seconds(1)
        waitOperation.input = waitTime
        let startTime = Date()
        let expectation = self.expectation(
            description: "Wait operation did not wait the correct amount of time.")
        waitOperation.completionBlock = {
            let endTime = Date()
            let difference = endTime.timeIntervalSince(startTime)
            if abs(difference - waitTime) < TimeInterval.milliseconds(100) {
                expectation.fulfill()
            }
        }
        concurrentQueue.addOperation(waitOperation)
        wait(for: [expectation],
             timeout: waitTime + TimeInterval.seconds(1))
    }

    func testFor_unavailableInput() {
        let waitOperation = WaitOperation()
        waitOperation.updateReady(true)
        let expectation = self.expectation(
            description: "Wait operation finishes with error.")
        waitOperation.completionBlock = { [weak waitOperation] in
            if waitOperation?.finishError != nil {
                expectation.fulfill()
            }
        }
        concurrentQueue.addOperation(waitOperation)
        wait(for: [expectation], timeout: TimeInterval.seconds(1))
    }

    func testFor_negativeTimeInterval() {
        let waitOperation = WaitOperation()
        let waitTime = TimeInterval.seconds(-1)
        waitOperation.input = waitTime
        let startTime = Date()
        let expectation = self.expectation(
            description: "Wait operation did not wait the correct amount of time.")
        waitOperation.completionBlock = {
            let endTime = Date()
            let difference = endTime.timeIntervalSince(startTime)
            if difference < TimeInterval.seconds(3) {
                expectation.fulfill()
            }
        }
        concurrentQueue.addOperation(waitOperation)
        wait(for: [expectation],
             timeout: waitTime + TimeInterval.seconds(10))
    }
}
