//
//  Event+JsonInitialization.swift
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
import CoreData

extension Event {
    var timezonedDates: [TimezonedDate] {
        return dates?.allObjects as? [TimezonedDate] ?? []
    }

    /// Creates an instance of Event.
    ///
    /// - Parameters:
    ///   - json: A json which contains Event's data.
    ///   - context: The context which is used to create the object.
    convenience init?(json: JSONDictionary,
                      context: NSManagedObjectContext) {
        var copy = json

        guard let eventTime = copy[JSONProperty.eventTime] as? String
            else { return nil }
        guard let time = CMTimeFormatter().timeFromString(eventTime)
            else { return nil }

        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Event",
                                                                 in: context)
            else { return nil }
        self.init(entity: entityDescription, insertInto: context)

        self.eventTime = eventTime
        self.cmEventTime = time
        copy[JSONProperty.eventTime] = nil
        otherFields = copy as NSDictionary
    }
}
