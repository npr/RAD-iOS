//
//  RangeCreationTestCase.swift
//  RAD-iOSDemoTests
//
//  Created by David Livadaru on 21/11/2018.
//  Copyright © 2018 NPR. All rights reserved.
//

import XCTest
import AVFoundation
import RAD

class RangeCreationTestCase: AnalyticsTestCase {
    private var rangeCreationExpectation: XCTestExpectation!

    override func setUp() {
        rangeCreationExpectation = self.expectation(
            description: "Analytics did create playback range.")

        super.setUp()

        debugger.addListeningObserver(self)
    }

    func testCaseForRangeCreation() {
        configureTestCase()
        executePlayback()
        wait(for: [rangeCreationExpectation], timeout: .minutes(1))
    }
}

extension RangeCreationTestCase: ListeningObserver {
    func didGenerateListeningRanges(_ ranges: [Object]) {
        guard let range = ranges.first else {
            XCTFail("Analytics created more than one range.")
            return
        }
        guard let startPlayerTime = playerTime(from: range, for: "start") else {
            XCTFail("Created range does not have start player time.")
            return
        }
        guard let endPlayerTime = playerTime(from: range, for: "end") else {
            XCTFail("Created range does not have start player time.")
            return
        }
        XCTAssert(
            startPlayerTime == "00:00:00.000",
            "Start player time is not correct.")
        XCTAssert(
            endPlayerTime.hasPrefix("00:00:03"),
            "End player time is not correct.")
        rangeCreationExpectation.fulfill()
    }

    private func playerTime(from object: Object, for key: String) -> String? {
        let keyObject = object[key] as? Object
        return keyObject?["playerTime"] as? String
    }
}
