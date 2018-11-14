//
//  SwiftMathFunctionTestSuite.swift
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

class SwiftMathFunctionTestSuite: XCTestCase {
    func testCaseFor_floorFunction() {
        let measurement = Measurement<UnitLength>(value: 1.2, unit: .meters)
        let expected = Measurement<UnitLength>(value: 1.0, unit: .meters)
        let floorValue = floor(measurement)
        XCTAssertTrue(
            floorValue.value.isEqual(to: expected.value),
            "Floor does not compute the value correctly.")
    }

    func testCaseFor_roundFunction_byPerformingFloor() {
        let measurement = Measurement<UnitLength>(value: 1.2, unit: .meters)
        let expected = Measurement<UnitLength>(value: 1.0, unit: .meters)
        let roundValue = round(measurement)
        XCTAssertTrue(
            roundValue.value.isEqual(to: expected.value),
            "Round does not compute the value correctly.")
    }

    func testCaseFor_roundFunction_byPerformingCeil() {
        let measurement = Measurement<UnitLength>(value: 1.78, unit: .meters)
        let expected = Measurement<UnitLength>(value: 2.0, unit: .meters)
        let roundValue = round(measurement)
        XCTAssertTrue(
            roundValue.value.isEqual(to: expected.value),
            "Round does not compute the value correctly.")
    }

//    func testCaseFor_ceilFunction() {
//        let measurement = Measurement<UnitLength>(value: 1.78, unit: .meters)
//        let expected = Measurement<UnitLength>(value: 2.0, unit: .meters)
//        let ceilValue = ceil(measurement)
//        XCTAssertTrue(
//            ceilValue.value.isEqual(to: expected.value),
//            "Ceil does not compute the value correctly.")
//    }

    func testCaseFor_roundingMeasurement_usingRound() {
        let centimeters = Measurement<UnitLength>(
            value: 190, unit: .centimeters)
        let meters = centimeters.converted(to: .meters)
        let expected = Measurement<UnitLength>(value: 2.0, unit: .meters)
        let rounded = roundingMeasurement(meters)
        XCTAssertTrue(
            rounded.value.isEqual(to: expected.value),
            "Rounding measurement does not compute value correctly.")
    }

    func testCaseFor_roundingMeasurement_usingFloor() {
        let decameters = Measurement<UnitLength>(
            value: 1.7, unit: .decameters)
        let expected = Measurement<UnitLength>(value: 1.0, unit: .decameters)
        let rounded = roundingMeasurement(decameters)
        XCTAssertTrue(
            rounded.value.isEqual(to: expected.value),
            "Rounding measurement does not compute value correctly.")
    }
}

extension UnitLength: Roundable {
    public static func lowestUnit<R>() -> R where R: Roundable {
        // swiftlint:disable next force_cast
        return UnitLength.meters as! R
    }
}
