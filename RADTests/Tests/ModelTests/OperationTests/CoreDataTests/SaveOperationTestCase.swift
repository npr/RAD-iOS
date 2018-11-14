//
//  SaveOperationTestCase.swift
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

class SaveOperationTestCase: OperationTestCase {
    func testCaseFor_skippingSave() {
        guard let context = Storage.shared?.backgroundQueueContext else {
            XCTFail("Context is not available")
            return
        }
        let operation = SaveContextOperation(context: context)
        XCTAssertFalse(context.hasChanges, "Context should not have any changes.")
        serialQueue.addOperations([operation], waitUntilFinished: true)
        XCTAssertFalse(context.hasChanges, "Context should not have any changes.")
    }

    func testCaseFor_contextIsSaved() {
        guard let context = Storage.shared?.backgroundQueueContext else {
            XCTFail("Context is not available.")
            return
        }

        _ = Server(
            urlString: "https://remoteaudiodata.npr.org", context: context)
        XCTAssertTrue(context.hasChanges, "Context should have any changes.")
        let operation = SaveContextOperation(context: context)
        serialQueue.addOperations([operation], waitUntilFinished: true)
        XCTAssertFalse(context.hasChanges, "Context should not have any changes.")
    }
}
