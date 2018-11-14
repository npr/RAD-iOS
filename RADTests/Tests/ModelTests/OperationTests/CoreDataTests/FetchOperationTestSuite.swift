//
//  FetchOperationTestSuite.swift
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
import CoreData
@testable import RAD

class FetchOperationTestSuite: OperationTestCase {
    override func setUp() {
        Storage.shared?.load()
    }

    func testCaseFor_serverFetch() {
        guard let context = Storage.shared?.mainQueueContext else {
            XCTFail("Context is not available.")
            return
        }

        _ = Server(
            urlString: "https://remoteaudiodata.npr.org", context: context)
        let saveOperation = SaveContextOperation(context: context)

        let fetchOperation = FetchOperation<Server>(context: context)
        fetchOperation.addDependency(saveOperation)
        let expectation = self.expectation(
            description: "Fetch was successful.")
        let inputOperation = ClosureInputOperation<[Server]> { servers in
            if servers.count > 0 {
                expectation.fulfill()
            }
        }
        fetchOperation.chainOperation(with: inputOperation)
        serialQueue.addOperations(
            [saveOperation, fetchOperation, inputOperation],
            waitUntilFinished: false)
        wait(for: [expectation], timeout: TimeInterval.seconds(2))
    }

    func testCaseFor_unknownEntity() {
        guard let context = Storage.shared?.mainQueueContext else {
            XCTFail("Context is not available.")
            return
        }

        let operation = FetchOperation<NonModelClass>(context: context)
        let expectation = self.expectation(
            description: "Entity should not found in the database model.")
        operation.completionBlock = { [weak operation] in
            if operation?.finishError != nil {
                expectation.fulfill()
            }
        }
        serialQueue.addOperation(operation)
        wait(for: [expectation], timeout: TimeInterval.seconds(2))
    }
}

private class NonModelClass: NSManagedObject {
}
