//
//  TimeComponents.swift
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

struct TimeComponents {
    let hours: Measurement<UnitDuration>
    let minutes: Measurement<UnitDuration>
    let seconds: Measurement<UnitDuration>

    var timeInterval: TimeInterval {
        return total.converted(to: .seconds).value
    }

    var total: Measurement<UnitDuration> {
        return hours + minutes + seconds
    }

    init(hours: Double = 0, minutes: Double = 0, seconds: Double = 0) {
        self.hours = Measurement<UnitDuration>(value: hours, unit: .hours)
        self.minutes = Measurement<UnitDuration>(value: minutes, unit: .minutes)
        self.seconds = Measurement<UnitDuration>(value: seconds, unit: .seconds)
    }

    init?(timeInterval: TimeInterval) {
        guard !timeInterval.isNaN else { return nil }

        let time = Measurement<UnitDuration>(value: timeInterval, unit: .seconds)
        let computedHours = time.converted(to: .hours)
        let hours = roundingMeasurement(computedHours)
        let computedMinutes = (computedHours - hours).converted(to: .minutes)
        let minutes = roundingMeasurement(computedMinutes)
        let computedMilliseconds = (computedMinutes - minutes).converted(
            to: .milliseconds)
        let seconds = roundingMeasurement(computedMilliseconds).converted(
            to: .seconds)

        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }

    init?(string: String, componentsSeparator: String) {
        let components = string.components(separatedBy: componentsSeparator)
        guard components.count >= 3 else { return nil }

        guard let hours = Double.from(string: components[0]) else { return nil }
        guard let minutes = Double.from(string: components[1]) else { return nil }
        guard let seconds = Double.from(string: components[2]) else { return nil }

        self.hours = Measurement<UnitDuration>(value: hours, unit: .hours)
        self.minutes = Measurement<UnitDuration>(value: minutes, unit: .minutes)
        self.seconds = Measurement<UnitDuration>(value: seconds, unit: .seconds)
    }
}
