//
//  RadMetadata+JsonInitialization.swift
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

extension RadMetadata {
    var metadataRelationsArray: [MetadataRelation] {
        return metadataRelations?.allObjects as? [MetadataRelation] ?? []
    }

    /// Creates an instance of RadMetadata.
    ///
    /// - Parameters:
    ///   - json: A json which contains RadMetadata's data.
    ///   - context: The context which is used to create the object.
    convenience init?(json: JSONDictionary,
                      context: NSManagedObjectContext) {
        guard json[JSONProperty.events] != nil else { return nil }

        guard let entityDescription = NSEntityDescription.entity(forEntityName: "RadMetadata",
                                                                 in: context)
            else { return nil }
        self.init(entity: entityDescription, insertInto: context)

        var copy = json
        copy[JSONProperty.events] = nil
        otherFields = copy as NSDictionary
    }
}
