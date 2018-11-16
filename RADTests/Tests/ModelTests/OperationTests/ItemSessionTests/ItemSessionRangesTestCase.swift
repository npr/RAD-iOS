//
//  ItemSessionRangesTestCase.swift
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
import AVFoundation
@testable import RAD

class ItemSessionRangesTestCase: AnalyticsTestCase, RADExtractionTestCase {
    func testCreationOfRanges() {
        let item: AVPlayerItem! = findResource(name: "100Events")

        guard let context = Storage.shared?.backgroundQueueContext else {
            XCTFail("Database is not available.")
            return
        }

        createRanges(in: context, for: item)

        guard let md5 = extractMD5(from: item) else {
            XCTFail("MD5 extraction failed")
            return
        }

        let fetchExpectation = fetchItemSessions(
            for: md5, from: context, completion: { itemSessions in
                let ranges = itemSessions.flatMap({ itemSession -> [RAD.Range] in
                    itemSession.playbackRanges?.allObjects as? [RAD.Range] ?? []
                })
                self.checkRanges(ranges, from: context, for: item)
        })

        wait(for: [fetchExpectation], timeout: TimeInterval.minutes(1))
    }

    // MARK: Private functionality

    private func createRanges(
        in context: NSManagedObjectContext,
        for item: AVPlayerItem
    ) {
        player.replaceCurrentItem(with: item)

        let seekExpectation = self.expectation(description: "Seek to second 7.")
        let pauseExpectation = self.expectation(
            description: "Pause on second 10.")

        DispatchQueue.background.asyncAfter(deadline: .now() + .seconds(5)) {
            let time = CMTime(
                seconds: 7.0, preferredTimescale: CMTime.TimeScale.podcast)
            self.player.seek(to: time)
            seekExpectation.fulfill()
            DispatchQueue.background.asyncAfter(
                deadline: .now() + .seconds(3),
                execute: {
                    self.player.pause()
                    pauseExpectation.fulfill()
            })
        }

        wait(
            for: [seekExpectation, pauseExpectation],
            timeout: TimeInterval.seconds(15))
    }

    private func fetchItemSessions(
        for md5: String,
        from context: NSManagedObjectContext,
        completion: @escaping ([ItemSession]) -> Void
    ) -> XCTestExpectation {
        let fetchSessionIDOperation = FetchOperation<ItemSessionID>(
            context: context)
        fetchSessionIDOperation.input = NSPredicate(
            format: "rad.md5 == '\(md5)'", argumentArray: nil)
        let expectation = self.expectation(
            description: "Item Session ID fetch.")
        let inputOperation = ClosureInputOperation<[ItemSessionID]>(
            closure: { ids in
                XCTAssert(
                    ids.count == 1,
                    "Item object was not created or it was duplicated.")
                let itemSessions = ids.first?.itemSessions?.allObjects as? [ItemSession]
                if let itemSessions = itemSessions, itemSessions.count == 1 {
                    completion(itemSessions)
                    expectation.fulfill()
                } else {
                    XCTFail("Item session was not created or it was duplicated.")
                }
        })
        fetchSessionIDOperation.chainOperation(with: inputOperation)

        serialQueue.addOperations(
            [fetchSessionIDOperation, inputOperation], waitUntilFinished: false)
        return expectation
    }

    private func checkRanges(
        _ ranges: [RAD.Range],
        from context: NSManagedObjectContext,
        for item: AVPlayerItem
    ) {
        ranges.forEach({ range in
            guard let start = range.start else {
                XCTFail("Invalid range.")
                return
            }
            guard let end = range.end else {
                XCTFail("Invalid range.")
                return
            }
            if start.playerTime?.seconds.equals(to: 0, precision: 1) == true {
                XCTAssert(
                    end.playerTime?.seconds.equals(to: 5, precision: 1) == true,
                    "Recorded range is not valid")
            } else if start.playerTime?.seconds.equals(to: 7, precision: 1) == true {
                XCTAssert(
                    end.playerTime?.seconds.equals(to: 10, precision: 1) == true,
                    "Recorded range is not valid")
            } else {
                XCTFail("Recorded range is not valid")
            }
        })
    }
}
