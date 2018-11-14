//
//  DictionaryRawRepresentableTestCase.swift
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

private enum PropertyKey: String {
    case key
}

class DictionaryRawRepresentableTestCase: XCTestCase {
    func testGetterSetter() {
        let value = "Value for raw representable dictionary."
        var dictionary: [String: String] = [:]
        dictionary[PropertyKey.key] = value
        let getValue = dictionary[PropertyKey.key]
        XCTOptionalAssertEqual(
            getValue,
            value,
            "Set value using raw representable keys are not returned back.")
    }
}
