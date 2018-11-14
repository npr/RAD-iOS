//
//  TimezonedDate+ObjectConvertible.swift
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

extension TimezonedDate: ObjectConvertible {
    var object: Object {
        var dictionary = self.json
        if let event = self.event {
            dictionary.merge(event.object, uniquingKeysWith: { current, _ in
                return current
            })
        }
        if metadataRelationsArray.count > 0 {
            dictionary["sessions"] = metadataRelationsArray.compactMap({
                $0.sessionId
            })
        }
        return dictionary
    }
}
