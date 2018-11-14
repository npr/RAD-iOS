//
//  BatchEventsOperation.swift
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

class BatchEventsOperation: OutputOperation<[Batch]> {
    typealias AppendingBatch = (_: inout Batch, _: inout [Batch]) -> Void
    private let configuration: Configuration
    private let server: Server
    private let context: NSManagedObjectContext

    init(
        configuration: Configuration,
        server: Server,
        context: NSManagedObjectContext
    ) {
        self.configuration = configuration
        self.server = server
        self.context = context
    }

    override func execute() {
        context.perform {
            var batches: [Batch] = []
            var currentBatch = Batch(server: self.server)
            let batchSize = Int(self.configuration.batchSize)
            self.server.metadataRelationsArray.forEach({
                let requiredCount = batchSize - currentBatch.datesCount

                let availableDates = $0.timezonedDates.sorted(by: {
                    $0.intervalSince1970 < $1.intervalSince1970
                })
                let count = min(requiredCount, availableDates.count)
                let groupedDates = [TimezonedDate](availableDates[..<count])

                currentBatch.groups.append(
                    MetadataGroup(metadata: $0, dates: groupedDates))

                let appendBatch: AppendingBatch = { currentBatch, batches in
                    if currentBatch.datesCount == batchSize {
                        batches.append(currentBatch)
                        currentBatch = Batch(server: self.server)
                    }
                }

                appendBatch(&currentBatch, &batches)

                var index = 0
                let indexCompute: (Int) -> Int = {
                    return count + $0 * batchSize
                }
                while indexCompute(index) < availableDates.count {
                    let upperBound = min(
                        indexCompute(index + 1), availableDates.count)
                    let range = indexCompute(index)..<upperBound
                    index += 1
                    let dates = [TimezonedDate](availableDates[range])
                    currentBatch.groups.append(
                        MetadataGroup(metadata: $0, dates: dates))

                    appendBatch(&currentBatch, &batches)
                }
            })

            if currentBatch.datesCount > 0,
                currentBatch.datesCount < batchSize {
                batches.append(currentBatch)
            }

            self.finish(with: batches)
        }
    }
}
