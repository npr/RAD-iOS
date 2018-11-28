//
//  SanityCheckTestCase.swift
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

class SanityCheckTestCase: XCTestCase {
    private var analytics: Analytics?
    private var player: AVPlayer?

    func testSanityCheck() {
        configureAnalytics()
        playASong()
        cleanObjects()
        configureAnalytics()
        checkForUnlockedObjects()
    }

    private func configureAnalytics() {
        analytics = Analytics()
        let player = AVPlayer(playerItem: nil)
        self.player = player
        analytics?.observePlayer(player)
    }

    private func playASong() {
        let item = findResource(name: "1_000Events")
        player?.replaceCurrentItem(with: item)
        player?.play()

        let stopExpectation = self.expectation(description: "Player did stop.")
        DispatchQueue.concurrent.asyncAfter(
            deadline: .now() + .seconds(3), execute: {
                self.player?.pause()
                self.player?.replaceCurrentItem(with: nil)
                stopExpectation.fulfill()
        })

        wait(for: [stopExpectation], timeout: .seconds(5))
    }

    private func cleanObjects() {
        player = nil
        analytics = nil
    }

    private func checkForUnlockedObjects() {
        wait(
            for: [radObjectsExpectation(),
                  sessionIDObjectsExpectation(),
                  itemSessionObjectsExpectation()],
            timeout: .seconds(20))
    }

    private func radObjectsExpectation() -> XCTestExpectation {
        let radExpectation = self.expectation(
            description: "Rad objects checked.")
        analytics?.debugger.objects(for: .rad, completion: { objects in
            let lockedObjects = objects.filter({ object in
                guard let isLocked = object["isLocked"] as? Bool else {
                    return false
                }
                return isLocked
            })
            XCTAssert(
                lockedObjects.count == 0,
                "There locked Rad objects in database.")
            radExpectation.fulfill()
        })
        return radExpectation
    }

    private func sessionIDObjectsExpectation() -> XCTestExpectation {
        let sessionIDExpectation = self.expectation(
            description: "Session ID objects checked.")
        analytics?.debugger.objects(
            for: .itemSessionId, completion: { objects in
                let lockedObjects = objects.filter({ object in
                    guard let isLocked = object["isLocked"] as? Bool else {
                        return false
                    }
                    return isLocked
                })
                XCTAssert(
                    lockedObjects.count == 0,
                    "There locked Session ID objects in database.")
                sessionIDExpectation.fulfill()
        })
        return sessionIDExpectation
    }

    private func itemSessionObjectsExpectation() -> XCTestExpectation {
        let itemSessionExpectation = self.expectation(
            description: "Item session objects checked.")
        analytics?.debugger.objects(for: .rad, completion: { objects in
            let lockedObjects = objects.filter({ object in
                guard let isActive = object["isActive"] as? Bool else {
                    return false
                }
                return isActive
            })
            XCTAssert(
                lockedObjects.count == 0,
                "There locked Rad objects in database.")
            itemSessionExpectation.fulfill()
        })
        return itemSessionExpectation
    }
}
