//
//  RangeBound+CoreDataProperties.swift
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

extension RangeBound {
    @nonobjc class func fetchRequest() -> NSFetchRequest<RangeBound> {
        return NSFetchRequest<RangeBound>(entityName: "RangeBound")
    }

    var playerTime: CMTime? {
        get {
            return playerTimeValue?.timeValue
        }
        set {
            guard let newValue = newValue else {
                playerTimeValue = nil
                return
            }

            playerTimeValue = NSValue(time: newValue)
        }
    }

    @NSManaged var playerTimeValue: NSValue?
    @NSManaged var date: TimezonedDate?
    @NSManaged var rangeForEnd: Range?
    @NSManaged var rangeForStart: Range?

}
