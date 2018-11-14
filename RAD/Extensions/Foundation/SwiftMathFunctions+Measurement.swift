//
//  SwiftMathFunctions+Measurement.swift
//  RAD
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

import Foundation

func floor<U: Unit>(_ measurement: Measurement<U>) -> Measurement<U> {
    return Measurement<U>(
        value: floor(measurement.value), unit: measurement.unit)
}

func round<U: Unit>(_ measurement: Measurement<U>) -> Measurement<U> {
    return Measurement<U>(
        value: round(measurement.value), unit: measurement.unit)
}

func roundingMeasurement<U>(
    _ measurement: Measurement<U>
) -> Measurement<U> where U: Dimension, U: Roundable {
    let roundMeasurement = round(measurement)
    let delta = Measurement<U>(value: 1.0, unit: U.lowestUnit())
    if roundMeasurement - measurement < delta {
        return roundMeasurement
    } else {
        return floor(measurement)
    }
}
