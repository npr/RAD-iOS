//
//  CMTimeFormatterTests.swift
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
import CoreMedia
@testable import RAD

class CMTimeFormatterTests: XCTestCase {
    func testWellFormattedTimeString() {
        let formatter = CMTimeFormatter()
        let timeComponents = TimeComponents(minutes: 10, seconds: 3.2)
        let time = CMTime(seconds: timeComponents.timeInterval,
                          preferredTimescale: CMTime.TimeScale.podcast)
        let formattedtime = formatter.stringFromTime(time)
        XCTAssertNotNil(formattedtime)
        XCTAssertEqual(formattedtime, "00:10:03.200",
                       "Time is not formatted properly.")
    }

    func testWellFormattedTimeString_wrongString() {
        let formatter = CMTimeFormatter()
        let timeComponents = TimeComponents(minutes: 26, seconds: 3.528)
        let time = CMTime(seconds: timeComponents.timeInterval,
                          preferredTimescale: CMTime.TimeScale.podcast)
        let formattedtime = formatter.stringFromTime(time)
        XCTAssertNotNil(formattedtime)
        XCTAssertNotEqual(formattedtime, "00:26:03,528",
                          "Time is not formatted properly.")
    }

    func testWellFormattedTimeString2() {
        let formatter = CMTimeFormatter()
        let timeComponents = TimeComponents(hours: 3, minutes: 47,
                                            seconds: 34.782)
        let time = CMTime(seconds: timeComponents.timeInterval,
                          preferredTimescale: CMTime.TimeScale.podcast)
        let formattedtime = formatter.stringFromTime(time)
        XCTAssertNotNil(formattedtime)
        XCTAssertEqual(formattedtime, "03:47:34.782",
                       "Time is not formatted properly.")
    }

    func testCMTimeFromString() {
        let formatter = CMTimeFormatter()
        let time = formatter.timeFromString("00:10:03.200")
        XCTAssertNotNil(time)
        XCTAssert(time == CMTime(seconds: 603.2,
                                 preferredTimescale: CMTime.TimeScale.podcast),
                  "Time is not converted from well formatted string.")
    }

    func testCMTimeFromString2() {
        let formatter = CMTimeFormatter()
        let time = formatter.timeFromString("00:26:03.528")
        XCTAssertNotNil(time)
        XCTAssert(time == CMTime(seconds: 1563.528,
                                 preferredTimescale: CMTime.TimeScale.podcast),
                  "Time is not converted from well formatted string.")
    }

    func testCMTimeFromString3() {
        let formatter = CMTimeFormatter()
        let time = formatter.timeFromString("03:47:34.782")
        XCTAssertNotNil(time)
        XCTAssert(time == CMTime(seconds: 13654.782,
                                 preferredTimescale: CMTime.TimeScale.podcast),
                  "Time is not converted from well formatted string.")
    }

    func testIllFormedString() {
        let formatter = CMTimeFormatter()
        let time = formatter.timeFromString("1::")
        XCTAssertNil(time, "Formatter accepted an ill-formed string")
    }

    func testValidString() {
        let formatter = CMTimeFormatter()
        let time = formatter.timeFromString("1:0:0")
        XCTAssert(time == CMTime(seconds: 3600.0,
                                 preferredTimescale: CMTime.TimeScale.podcast),
                  "Formatter is not able format a valid string.")
    }

    func testFormatEquality() {
        let formatter = CMTimeFormatter()
        let time = formatter.timeFromString("0:0:1.000")
        let otherTime = formatter.timeFromString("00:00:01.000")

        XCTAssert(
            time == otherTime, "Equivalent formats do not create equal CMTime.")
    }
}
