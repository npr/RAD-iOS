//
//  KVOExpectation.swift
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
import XCTest

class KVOExpectation<T: NSObject, Value: Equatable>: XCTestExpectation {
    let object: T
    private var observation: Any?

    init(
        description expectationDescription: String,
        object: T,
        keyPath: KeyPath<T, Value>,
        expectedValue: Value
    ) {
        self.object = object
        super.init(description: expectationDescription)
        observation = object.observe(
            keyPath,
            options: [.new],
            changeHandler: { [weak self] (_, change: NSKeyValueObservedChange<Value>) in
                if change.newValue == expectedValue {
                    self?.fulfill()
                }
        })
    }
}
