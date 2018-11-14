//
//  GenericObjectContainer.swift
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

/// A subclass which simplifies the usage of otherFields property.
class GenericObjectContainer: NSManagedObject {
    @NSManaged var md5: String?
    @NSManaged var otherFields: NSDictionary?

    var json: JSONDictionary {
        return otherFields as? JSONDictionary ?? [:]
    }

    func updateOtherFields(_ closure: (_ json: JSONDictionary?) -> JSONDictionary?) {
        otherFields = closure(json) as NSDictionary?
    }
}
