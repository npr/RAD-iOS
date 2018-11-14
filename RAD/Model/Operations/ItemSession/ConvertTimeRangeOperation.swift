//
//  ConvertTimeRangeOperation.swift
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

class ConvertTimeRangeOperation: ChainOperation<ItemSession, [Range]> {
    private let timeRange: TimeRange
    private let context: NSManagedObjectContext

    init(timeRange: TimeRange, context: NSManagedObjectContext) {
        self.timeRange = timeRange
        self.context = context
    }

    override func execute() {
        guard let itemSession = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }
        context.perform {
            let range = Range(context: self.context)
            range.start = self.createStartBound()
            range.end = self.createEndBound()
            range.itemSession = itemSession
            self.finish(with: [range])
        }
    }

    // MARK: Private functionality

    private func createStartBound() -> RangeBound {
        let start = RangeBound(context: self.context)
        start.playerTime = timeRange.start.playerTime
        start.date = createTimezoneDate(from: timeRange.start)
        return start
    }

    private func createEndBound() -> RangeBound {
        let end = RangeBound(context: context)
        end.playerTime = timeRange.end.playerTime
        end.date = createTimezoneDate(from: timeRange.end)
        return end
    }

    private func createTimezoneDate(
        from bound: TimeRangeBound) -> TimezonedDate? {
        guard let intervalSince1970 = bound.intervalSince1970 else {
            return nil
        }
        guard let timezoneOffset = bound.timezoneOffset else {
            return nil
        }

        let timezonedDate = TimezonedDate(context: context)
        timezonedDate.intervalSince1970 = intervalSince1970
        timezonedDate.timezoneOffset = Int64(timezoneOffset)
        return timezonedDate
    }
}
