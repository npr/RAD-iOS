//
//  TimeInterval+Components.swift
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

public extension TimeInterval {
    /// Create a TimeInterval value based on the provided hours.
    ///
    /// - Parameter hours: The amount of hours to be converted.
    /// - Returns: The amound of seconds as TimeInterval.
    static func hours(_ hours: Double) -> TimeInterval {
        let hoursMeasurement = Measurement<UnitDuration>(
            value: hours, unit: .hours)
        let secondsMeasurement = hoursMeasurement.converted(to: .seconds)
        return secondsMeasurement.value
    }

    /// Create a TimeInterval value based on the provided minutes.
    ///
    /// - Parameter minutes: The amount of minutes to be converted.
    /// - Returns: The amound of seconds as TimeInterval.
    static func minutes(_ minutes: Double) -> TimeInterval {
        let minutesMeasurement = Measurement<UnitDuration>(
            value: minutes, unit: .minutes)
        let secondsMeasurement = minutesMeasurement.converted(to: .seconds)
        return secondsMeasurement.value
    }

    /// Create a TimeInterval value based on the provided seconds.
    ///
    /// - Parameter seconds: The amount of seconds.
    /// - Returns: The amount of seconds.
    static func seconds(_ seconds: Double) -> TimeInterval {
        return seconds
    }

    /// Create a TimeInterval value based on the provided milliseconds.
    ///
    /// - Parameter milliseconds: The amount of milliseconds to be converted.
    /// - Returns: The amound of seconds as TimeInterval.
    static func milliseconds(_ milliseconds: Double) -> TimeInterval {
        let millisecondsMeasurement = Measurement<UnitDuration>(
            value: milliseconds, unit: .milliseconds)
        let secondsMeasurement = millisecondsMeasurement.converted(to: .seconds)
        return secondsMeasurement.value
    }
}
