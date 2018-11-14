//
//  RangeReplaceableCollection+Operators.swift
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

extension RangeReplaceableCollection {
    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        var copy = lhs
        copy.append(contentsOf: rhs)
        return copy
    }

    static func + (_ lhs: Self, _ rhs: Element) -> Self {
        var copy = lhs
        copy.append(rhs)
        return copy
    }

    static func += (_ lhs: inout Self, _ rhs: Self) {
        lhs.append(contentsOf: rhs)
    }

    static func += (_ lhs: inout Self, _ rhs: Element) {
        lhs.append(rhs)
    }
}
