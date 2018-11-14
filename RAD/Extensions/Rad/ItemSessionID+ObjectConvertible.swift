//
//  ItemSessionID+ObjectConvertible.swift
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

extension ItemSessionID: ObjectConvertible {
    var object: Object {
        var json: Object = ["isLocked": isLocked]
        if let count = self.itemSessions?.count {
            json["sessions count"] = count
        }

        json["creation date"] = creationIntervalSince1970
        if let identifier = identifier {
            json["identifier"] = identifier
        }
        if let rad = rad {
            json["Rad md5"] = rad.md5
        }
        return json
    }
}
