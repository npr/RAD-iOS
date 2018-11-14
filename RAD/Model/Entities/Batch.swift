//
//  Batch.swift
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

struct Batch {
    let server: Server
    var groups: [MetadataGroup]

    var datesCount: Int {
        return groups.reduce(0, { $0 + $1.dates.count })
    }

    var dates: [TimezonedDate] {
        return groups.flatMap({ $0.dates })
    }

    var json: JSONDictionary {
        var json: JSONDictionary = [:]
        let metadataObjects: JSONArray = groups.compactMap({
            guard let count = $0.metadata.dates?.count, count > 0
                else { return nil }
            var json = $0.metadata.json
            json[RadMetadata.JSONProperty.events] = $0.dates.map({ $0.json })
            return json
        })
        json[Server.JSONProperty.audioSessions] = metadataObjects
        return json
    }

    init(server: Server, groups: [MetadataGroup] = []) {
        self.server = server
        self.groups = groups
    }
}
