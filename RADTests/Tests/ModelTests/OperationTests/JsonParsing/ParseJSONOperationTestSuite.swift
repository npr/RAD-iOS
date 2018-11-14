//
//  ParseJSONOperationTestSuite.swift
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

class ParseJSONOperationTestSuite: OperationTestCase {
    func testCaseFor_successfulJSONParsing() {
        let operation = ParseJSONOperation<[String]>()
        operation.input = "[\"a\", \"b\"]"
        let expectation = self.expectation(
            description: "JSON parsing was successful.")
        let input = ClosureInputOperation<[String]> { strings in
            if strings == ["a", "b"] {
                expectation.fulfill()
            }
        }
        operation.chainOperation(with: input)
        concurrentQueue.addOperations(
            [operation, input], waitUntilFinished: false)
        wait(for: [expectation], timeout: TimeInterval.milliseconds(100))
    }

    func testCaseFor_unavailableInput() {
        let operation = ParseJSONOperation<[String]>()
        operation.updateReady(true)
        let expectation = self.expectation(
            description: "JSON parsing did fail.")
        operation.completionBlock = { [weak operation] in
            if operation?.finishError != nil {
                expectation.fulfill()
            }
        }
        concurrentQueue.addOperation(operation)
        wait(for: [expectation], timeout: TimeInterval.seconds(1))
    }

    func testCaseFor_failedJSONParsing() {
        let operation = ParseJSONOperation<[String]>()
        operation.input = "{\"key\":\"value;forgot closing brace\""
        let expectation = self.expectation(
            description: "JSON parsing did fail.")
        operation.completionBlock = { [weak operation] in
            if operation?.finishError != nil {
                expectation.fulfill()
            }
        }
        concurrentQueue.addOperation(operation)
        wait(for: [expectation], timeout: TimeInterval.seconds(1))
    }

    func testCaseFor_mismatchJSONTypes() {
        let operation = ParseJSONOperation<JSONDictionary>()
        operation.input = "[\"a\", \"b\"]"
        let expectation = self.expectation(
            description: "JSON parsing did fail.")
        operation.completionBlock = { [weak operation] in
            if operation?.finishError != nil {
                expectation.fulfill()
            }
        }
        concurrentQueue.addOperation(operation)
        wait(for: [expectation], timeout: TimeInterval.seconds(1))
    }
}
