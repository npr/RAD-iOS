//
//  XCTest+MessageOption.swift
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

/// If message is empty, then default message is returned
///
/// - Parameters:
///   - message: The message which is tested.
///   - defaultMessage: The default message to be used if message is empty.
/// - Returns: The *message* if not empty, *defaultMessage* otherwise.
func chooseMessage(_ message: String, _ defaultMessage: String) -> String {
    return message.isEmpty ? defaultMessage : message
}
