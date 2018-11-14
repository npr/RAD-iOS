//
//  ClosureInputOperation.swift
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

/// An input operation which facilitates ease of access to a value computed
/// by another operation within a closure.
///
/// The operation finishes after calling the closure.
/// For async support see AsyncClosureInputOperation.
class ClosureInputOperation<Input>: InputOperation<Input> {
    typealias Closure = (_ input: Input) -> Void

    private let closure: Closure

    init(closure: @escaping Closure) {
        self.closure = closure
    }

    override func execute() {
        guard let input = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        closure(input)
        finish()
    }
}
