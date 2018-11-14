//
//  Event+CoreDataClass.swift
//  RADTestApplication
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
import CoreData
import CoreMedia

@objc(Event)
class Event: GenericObjectContainer {
    var cmEventTime: CMTime?

    enum JSONProperty: String, CodingKey {
        case eventTime, timestamp
    }

    override var json: JSONDictionary {
        var copy = super.json
        copy[JSONProperty.eventTime] = eventTime
        return copy
    }
}
