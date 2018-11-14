//
//  ContextTrasnferFetchTestSuite.swift
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

class ContextTrasnferFetchTestSuite: OperationTestCase {
    override func setUp() {
        Storage.shared?.load()
    }

    func testContextTransfer() {
        guard let backgroundContext = Storage.shared?.backgroundQueueContext
            else { return }
        guard let mainContext = Storage.shared?.mainQueueContext else { return }
        let url = "https://remoteaudio.npr.org"
        let operation = CreateServerOperation(url:
            url, context: backgroundContext)
        operation.completionBlock = { [weak operation] in
            if operation?.finishError != nil {
                XCTFail("Failed to finish with")
            }
        }
        fetch(
            url: url,
            afterOperation: operation,
            fromContext: backgroundContext,
            toContext: mainContext
        ) { assertion in
            XCTAssertTrue(
                assertion, "Object was not transferred between objects.")
        }
    }

    func fetch(
        url: String,
        afterOperation operation: OutputOperation<[Server]>,
        fromContext: NSManagedObjectContext,
        toContext: NSManagedObjectContext,
        completion: @escaping (_ successful: Bool) -> Void
    ) {
        let transferOperation = ContextTransferOperation<Server>(
            context: fromContext)
        operation.chainOperation(with: transferOperation)
        let fetchOperation = ContextFetchOperation<Server>(context: toContext)
        transferOperation.chainOperation(with: fetchOperation)
        let inputOperation = ClosureInputOperation<[Server]> { servers in
            toContext.perform {
                let object = servers.first(where: {
                    $0.trackingUrl == url
                })
                completion(object != nil)
            }
        }
        fetchOperation.chainOperation(with: inputOperation)
        serialQueue.addOperations(
            [operation, transferOperation, fetchOperation, inputOperation],
            waitUntilFinished: false)
    }

    func testCaseFor_transferOperation_unableInput() {
        guard let mainContext = Storage.shared?.mainQueueContext else { return }
        let operation = ContextTransferOperation<Server>(context: mainContext)
        operation.updateReady(true)

        let expectation = self.expectation(
            description: "Context transfer operation does not have input.")
        operation.completionBlock = { [weak operation] in
            if operation?.finishError != nil {
                expectation.fulfill()
            }
        }

        serialQueue.addOperation(operation)
        wait(for: [expectation], timeout: TimeInterval.seconds(1))
    }

    func testCaseFor_contextFetchOperation_unableInput() {
        guard let mainContext = Storage.shared?.mainQueueContext else { return }
        let operation = ContextFetchOperation<Server>(context: mainContext)
        operation.updateReady(true)

        let expectation = self.expectation(
            description: "Context fetch operation does not have input.")
        operation.completionBlock = { [weak operation] in
            if operation?.finishError != nil {
                expectation.fulfill()
            }
        }

        serialQueue.addOperation(operation)
        wait(for: [expectation], timeout: TimeInterval.seconds(1))
    }
}

private class CreateServerOperation: OutputOperation<[Server]> {
    private let url: String
    private let context: NSManagedObjectContext

    init(url: String, context: NSManagedObjectContext) {
        self.url = url
        self.context = context
    }

    override func execute() {
        guard let server = Server(urlString: url, context: context) else {
            finish(with: OutputError.computationError)
            return
        }
        let saveOperation = SaveContextOperation(context: context)
        saveOperation.completionBlock = { [weak self] in
            self?.finish(with: [server])
        }
        OperationQueue.current?.addOperation(saveOperation)
    }
}
