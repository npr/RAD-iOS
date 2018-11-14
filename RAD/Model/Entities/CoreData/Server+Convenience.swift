//
//  Server+JsonInitialization.swift
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

extension Server {
    var trackingURI: URL? {
        guard let string = trackingUrl else { return nil }
        return URL(string: string)
    }

    var metadataRelationsArray: [MetadataRelation] {
        return metadataRelations?.allObjects as? [MetadataRelation] ?? []
    }

    /// Creates an instance of Server.
    ///
    /// - Parameters:
    ///   - urlString: Url as a string object.
    ///   - context: The context which is used to create the object.
    convenience init?(urlString: String,
                      context: NSManagedObjectContext) {
        guard URL(string: urlString) != nil else { return nil }

        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: "Server", in: context)
        else { return nil }

        self.init(entity: entityDescription, insertInto: context)

        trackingUrl = urlString
    }
}
