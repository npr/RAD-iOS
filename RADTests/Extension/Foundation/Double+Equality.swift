//
//  Double+Equality.swift
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

import Foundation

extension Double {
    /// Tests if self is equal with other using a precision.
    ///
    /// - Parameters:
    ///   - other: The other double value to test.
    ///   - precision: The precision which is used for testing.
    ///     *Default value* is 15 digits and is also the maximum allowed value.
    /// - Returns: *true* if self is equal with other, *false* otherwise.
    func equals(to other: Double, precision: Int = 15) -> Bool {
        let diff = self - other
        let argument = max(Double(-precision), -15.0)
        return abs(diff) < Double(pow(10.0, argument))
    }
}
