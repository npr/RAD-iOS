//
//  PrettyJSONOperation.swift
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

/// Format a json object in order to ready for print
/// (e.g.: display the json on UI.)
class PrettyJSONOperation<JSON>: ChainOperation<JSON, String> {
    override func execute() {
        guard let json = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        do {
            let data = try JSONSerialization.data(
                withJSONObject: json, options: [.prettyPrinted])
            if let prettyJson = String(data: data, encoding: .utf8) {
                finish(with: prettyJson)
            } else {
                finish(with: OutputError.computationError)
            }
        } catch {
            finish(with: error)
        }
    }
}
