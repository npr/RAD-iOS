//
//  WeakReferenceContainerTestCase.swift
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

class WeakReferenceContainerTestCase: XCTestCase {
    func testRemoval() {
        var container = WeakReferenceContainer<Helper>()
        let reference = ReferenceHelper(flag: false)
        container.append(reference)
        container.forEach { $0?.test() }
        XCTAssertTrue(reference.flag, "Container did not call helper.")

        container.remove(reference)
        container.forEach { $0?.test() }
        XCTAssertTrue(reference.flag, "Container did not call helper.")
    }
}

private protocol Helper {
    func test()
}

private class ReferenceHelper: Helper {
    private (set) var flag: Bool

    init(flag: Bool) {
        self.flag = flag
    }

    func test() {
        flag = !flag
    }
}
