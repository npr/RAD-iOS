//
//  HttpStatusCode.swift
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

struct HttpStatusCode: Hashable {
    enum Class {
        case informational, success, redirection, client, server, unknown
    }

    let code: Int
    let `class`: Class
    let description: String

    static func == (_ lhs: HttpStatusCode, _ rhs: HttpStatusCode) -> Bool {
        return lhs.code == rhs.code
    }
}
