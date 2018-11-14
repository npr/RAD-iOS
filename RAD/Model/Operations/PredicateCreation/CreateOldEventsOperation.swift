//
//  CreateOldEventsOperation.swift
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

class CreateOldEventsOperation: OutputOperation<NSPredicate> {
    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    override func execute() {
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = -configuration.expirationTimeInterval

        guard let date = calendar.date(
            byAdding: dateComponents, to: Date.now) else {
                finish(with: OutputError.computationError)
                return
        }
        let datePredicate = NSPredicate(
            format: "intervalSince1970 < %@",
            argumentArray: [date.timeIntervalSince1970])
        let relationPredicate = NSPredicate(
            format: "event != nil", argumentArray: nil)
        let compoundPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [datePredicate, relationPredicate])
        finish(with: compoundPredicate)
    }
}
