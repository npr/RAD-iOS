//
//  ParseRADPayloadOperationTestCase.swift
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
import AVFoundation
@testable import RAD

class ParseRADPayloadOperationTestCase: OperationTestCase {
    func testRADPayloadExtraction() {
        guard let url = Bundle.testBundle.url(
            forResource: "RAD_extra_properties",
            withExtension: "m4a"
        ) else {
            XCTFail("File resource is not available.")
            return
        }

        let asset = AVURLAsset(url: url)
        let operation = ParseRADPayloadOperation(asset: asset)
        let expectation = self.expectation(
            description: "RAD payload extraction.")
        let input = ClosureInputOperation<String> { _ in
            expectation.fulfill()
        }
        operation.chainOperation(with: input)

        concurrentQueue.addOperations(
            [operation, input], waitUntilFinished: false)
        wait(for: [expectation], timeout: TimeInterval.seconds(5))
    }
}
