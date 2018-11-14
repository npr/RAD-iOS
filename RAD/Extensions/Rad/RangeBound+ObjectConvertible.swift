//
//  RangeBound+ObjectConvertible.swift
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

extension RangeBound: ObjectConvertible {
    var object: Object {
        var json: Object = [:]
        if let time = self.playerTime,
            let playerTime = CMTimeFormatter().stringFromTime(time) {
            json["playerTime"] = playerTime
        }
        if let date = self.date {
            json.merge(date.object, uniquingKeysWith: { current, _ in
                return current
            })
        }
        return json
    }
}
