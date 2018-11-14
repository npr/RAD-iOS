//
//  NextScheduleOperationTestCase.swift
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

class NextScheduleOperationTestCase: OperationTestCase {
    override func tearDown() {
        super.tearDown()

        UserDefaults.standard.removeObject(
            forKey: UserDefaultsKeys.lastSchedule)
    }

    func testNextSchedule() {
        Scheduling.last = Date()
        let configuration = Configuration(
            submissionTimeInterval: TimeInterval.minutes(3),
            batchSize: 5,
            expirationTimeInterval: DateComponents(day: 1),
            sessionExpirationTimeInterval: TimeInterval.hours(24),
            requestHeaderFields: [:])
        let findOperation = FindNextSchedule(configuration: configuration)
        let expectation = self.expectation(
            description: "Next schedule is not computed correctly.")
        let inputOperation = ClosureInputOperation<TimeInterval> { time in
            let diff = time - Date().timeIntervalSinceNow
            if diff - configuration.submissionTimeInterval < TimeInterval.milliseconds(100) {
                expectation.fulfill()
            }
        }
        findOperation.chainOperation(with: inputOperation)
        serialQueue.addOperations(
            [findOperation, inputOperation],
            waitUntilFinished: false)
        wait(for: [expectation], timeout: TimeInterval.minutes(100))
    }
}
