//
//  FilterEventsOperation.swift
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

class FilterEventsOperation: InputOperation<RADPayload> {
    private let ranges: [Range]
    private let context: NSManagedObjectContext

    init(ranges: [Range], context: NSManagedObjectContext) {
        self.ranges = ranges
        self.context = context
    }

    override func execute() {
        guard let payload = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        context.perform {
            guard self.ranges.count > 0 else {
                self.deleteTemporaryObjects(from: payload)
                self.finish()
                return
            }

            let result = self.filter(events: payload.events, for: self.ranges)
            let unlistenedEvents = result.unused.filter({
                $0.objectID.isTemporaryID && $0.dates?.count == 0
            })
            self.context.deleteObjects([Event](unlistenedEvents))
            self.createRelations(for: result.dates, with: payload)
            self.finish()
        }
    }

    // MARK: Private functionality

    private func deleteTemporaryObjects(from payload: RADPayload) {
        var objectsToDelete: [NSManagedObject] =
            payload.events.filter({ event in
                event.objectID.isTemporaryID &&
                event.dates?.count == 0
            })
        objectsToDelete += payload.servers.filter({ server in
            server.objectID.isTemporaryID &&
            server.metadataRelations?.count == 0
        })
        let radMetadata = payload.radMetadata
        if radMetadata.objectID.isTemporaryID,
            radMetadata.metadataRelations?.count == 0 {
            objectsToDelete += payload.radMetadata
        }
        self.context.deleteObjects(objectsToDelete)
    }

    private func filter(events: [Event], for ranges: [Range]) -> FilterResult {
        var payloadEvents = Set<Event>(events)
        var savedEvents = Set<Event>()

        let sortedRanges = ranges.sorted { (left, right) -> Bool in
            guard let lhs = left.start?.date?.intervalSince1970 else {
                return false
            }
            guard let rhs = right.start?.date?.intervalSince1970 else {
                return false
            }
            return lhs < rhs
        }

        let dates = sortedRanges.flatMap({ range -> [TimezonedDate] in
            let filteredEvents = payloadEvents.filter({
                guard let time = $0.cmEventTime else { return false }
                return range.containsTime(time)
            })
            savedEvents.formUnion(filteredEvents)
            payloadEvents.subtract(filteredEvents)
            return computeTimestamp(for: filteredEvents, in: range)
        })

        return FilterResult(
            dates: dates, saved: savedEvents, unused: payloadEvents)
    }

    private func computeTimestamp(
        for events: Set<Event>, in range: Range
    ) -> [TimezonedDate] {
        guard let dateInterval = range.start?.date?.intervalSince1970 else {
            return []
        }
        guard let timezoneOffset = range.start?.date?.timezoneOffset else {
            return []
        }
        guard let rangeStartTime = range.start?.playerTime else { return [] }

        var dates: [TimezonedDate] = []

        events.forEach {
            guard let eventTime = $0.cmEventTime?.seconds else { return }

            let date = TimezonedDate(context: context)
            let rangeOffset = eventTime - rangeStartTime.seconds
            date.intervalSince1970 = dateInterval + rangeOffset
            date.timezoneOffset = timezoneOffset
            date.event = $0
            dates.append(date)
        }

        return dates
    }

    private func createRelations(
        for dates: [TimezonedDate], with payload: RADPayload
    ) {
        for server in payload.servers {
            let metadataRelation = MetadataRelation(context: self.context)
            metadataRelation.sessionId = payload.sessionId
            metadataRelation.server = server
            metadataRelation.radMetadata = payload.radMetadata
            dates.forEach({ date in
                date.addToMetadataRelations(metadataRelation)
            })
        }
    }
}
