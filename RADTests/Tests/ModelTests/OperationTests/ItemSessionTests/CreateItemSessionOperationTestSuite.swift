//
//  CreateItemSessionOperationTestSuite.swift
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
import CoreData
@testable import RAD

class CreateItemSessionOperationTestSuite: AnalyticsTestCase,
RADExtractionTestCase {

    func testCaseFor_objectsAreCreatedInDatabase() {
        let item: AVPlayerItem! = findResource(name: "1_000Events")

        play(item: item, for: .seconds(2))

        guard let context = Storage.shared?.backgroundQueueContext else {
            XCTFail("Database is not available.")
            return
        }

        guard let md5 = extractMD5(from: item) else {
            XCTFail("RAD payload is not available or MD5 creation failed.")
            return
        }

        let radExpectation = self.createRadExpectation(for: md5, from: context)
        let sessionExpectation = self.createSessionExpectation(
            for: md5, from: context)

        wait(
            for: [radExpectation, sessionExpectation],
            timeout: TimeInterval.seconds(5))
    }

    func testCaseFor_databaseObjectsAreUnlockedOrInactive() {
        guard let context = Storage.shared?.backgroundQueueContext else {
            XCTFail("Database is not available.")
            return
        }

        checkInactiveSession(in: context)
        checkUnlockedObjects(for: Rad.self, in: context)
        checkUnlockedObjects(for: ItemSessionID.self, in: context)
    }

    // MARK: Private functionality

    private func createRadExpectation(
        for md5: String,
        from context: NSManagedObjectContext
    ) -> XCTestExpectation {
        let fetchRADOperation = FetchOperation<Rad>(context: context)
        fetchRADOperation.input = NSPredicate(
            format: "md5 == '\(md5)'", argumentArray: nil)
        let expectation = self.expectation(
            description: "Rad fetch.")
        let inputOperation = ClosureInputOperation<[Rad]> {
            XCTAssert($0.count > 0, "Rad object was not created")
            XCTAssert($0.count < 2, "Rad object was duplicated.")
            expectation.fulfill()
        }
        fetchRADOperation.chainOperation(with: inputOperation)
        serialQueue.addOperations(
            [fetchRADOperation, inputOperation], waitUntilFinished: false)
        return expectation
    }

    private func createSessionExpectation(
        for md5: String, from context: NSManagedObjectContext
    ) -> XCTestExpectation {
        let fetchSessionIDOperation = FetchOperation<ItemSessionID>(
            context: context)
        fetchSessionIDOperation.input = NSPredicate(
            format: "rad.md5 == '\(md5)'", argumentArray: nil)
        let expectation = self.expectation(
            description: "Item Session ID fetch.")
        let inputOperation = ClosureInputOperation<[ItemSessionID]> {
            XCTAssert($0.count > 0, "Item object was not created")
            XCTAssert($0.count < 2, "Item object was duplicated.")
            let itemSessions = $0.first?.itemSessions?.allObjects as? [ItemSession]
            if itemSessions?.count == 0 {
                XCTFail("Item session was not created.")
            } else {
                expectation.fulfill()
            }
        }
        fetchSessionIDOperation.chainOperation(with: inputOperation)

        serialQueue.addOperations(
            [fetchSessionIDOperation, inputOperation], waitUntilFinished: false)
        return expectation
    }

    private func checkInactiveSession(in context: NSManagedObjectContext) {
        let fetchOperation = FetchOperation<ItemSession>(context: context)
        let fetchExpectation = self.expectation(
            description: "Item sessions checked.")
        let inputOperation = ClosureInputOperation<[ItemSession]> {
            $0.forEach({ itemSession in
                XCTAssertFalse(
                    itemSession.isActive, "Item session should be inactive.")
            })
            fetchExpectation.fulfill()
        }
        fetchOperation.chainOperation(with: inputOperation)

        serialQueue.addOperations(
            [fetchOperation, inputOperation],
            waitUntilFinished: false)

        wait(for: [fetchExpectation], timeout: TimeInterval.seconds(3))
    }

    private func checkUnlockedObjects<T: NSManagedObject & Lockable>(
        for type: T.Type,
        in context: NSManagedObjectContext
    ) {
        let fetchOperation = FetchOperation<T>(context: context)
        let fetchExpectation = self.expectation(
            description: "Lockable objects checked.")
        let inputOperation = ClosureInputOperation<[T]> {
            $0.forEach({ lockableObject in
                XCTAssertFalse(
                    lockableObject.isLocked, "Object should not be locked.")
            })
            fetchExpectation.fulfill()
        }
        fetchOperation.chainOperation(with: inputOperation)

        serialQueue.addOperations(
            [fetchOperation, inputOperation],
            waitUntilFinished: false)

        wait(for: [fetchExpectation], timeout: TimeInterval.seconds(3))
    }

    private func checkUnlockedRadObjects(in context: NSManagedObjectContext) {
        let fetchOperation = FetchOperation<ItemSession>(context: context)
        let fetchExpectation = self.expectation(
            description: "Item sessions expectation.")
        let inputOperation = ClosureInputOperation<[ItemSession]> {
            $0.forEach({ itemSession in
                XCTAssertFalse(
                    itemSession.isActive, "Item session should be inactive.")
            })
            fetchExpectation.fulfill()
        }
        fetchOperation.chainOperation(with: inputOperation)

        serialQueue.addOperations(
            [fetchOperation, inputOperation],
            waitUntilFinished: false)

        wait(for: [fetchExpectation], timeout: TimeInterval.seconds(3))
    }
}

private protocol Lockable {
    var isLocked: Bool { get }
}

extension RAD.Rad: Lockable {}
extension RAD.ItemSessionID: Lockable {}
