//
//  CMTimeFormatter.swift
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
import CoreMedia

/// A formatter which it handles conversion between String and CMTime.
class CMTimeFormatter {
    var timeScale = CMTime.TimeScale.podcast
    let componentsSeparator = ":"

    init() {}

    lazy var hoursFormatter: NumberFormatter  = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 2
        return numberFormatter
    }()

    lazy var minutesFormatter: NumberFormatter  = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 2
        return numberFormatter
    }()

    lazy var secondsFormatter: NumberFormatter  = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 2
        numberFormatter.minimumFractionDigits = 3
        return numberFormatter
    }()

    /// Convert CMTime object into a string object.
    ///
    /// - Parameter time: The time object.
    /// - Returns: The CMTime object as string or *nil* if conversion failed.
    func stringFromTime(_ time: CMTime) -> String? {
        guard let components = TimeComponents(
            timeInterval: time.seconds
        ) else { return nil }
        let numbers = [
            hoursFormatter.string(
                from: NSNumber(value: components.hours.value)),
            minutesFormatter.string(
                from: NSNumber(value: components.minutes.value)),
            secondsFormatter.string(
                from: NSNumber(value: components.seconds.value))
        ].compactMap({ $0 })
        return numbers.joined(separator: componentsSeparator)
    }

    /// Convert a string into a CMTime object.
    ///
    /// - Parameter string: The string to convert.
    /// - Returns: The CMTime object or *nil* if string is not formatted corerctly.
    func timeFromString(_ string: String) -> CMTime? {
        guard let components = TimeComponents(
            string: string, componentsSeparator: componentsSeparator
        ) else { return nil }
        return CMTime(seconds: components.timeInterval,
                      preferredTimescale: timeScale)
    }
}
