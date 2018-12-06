//
//  PlayerTestCase.swift
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

class PlayerTestCase: XCTestCase {
    var resourceName: String {
        return "50Events"
    }

    var resourceExtension: String {
        return "mp3"
    }

    var item: AVPlayerItem?

    private (set) var timeRangeController: TimeRangeController?
    private (set) var player: MockPlayer!

    override func setUp() {
        player = MockPlayer()

        guard let url = Bundle.testBundle.url(
            forResource: resourceName, withExtension: resourceExtension
        ) else {
            return
        }

        item = AVPlayerItem(url: url)

        player.replaceCurrentItem(with: item)

        timeRangeController = TimeRangeController(player: player)
    }

    override func tearDown() {
        super.tearDown()
        item = nil
    }
}
