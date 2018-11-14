//
//  ScheduleDataSend.swift
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

class ScheduleDataSend: Operation {
    typealias DataSendCompletion = (UIBackgroundFetchResult) -> Void
    private let configuration: Configuration
    private var repeats: Bool
    private let sentCompletion: DataSendCompletion?

    static func scheduleDataSend(configuration: Configuration) {
        let findNextSchedule = FindNextSchedule(configuration: configuration)
        let currentScheduleOperation =
            OperationQueue.background.operations.first(where: {
                return $0 is ScheduleDataSend && $0.isExecuting
            })
        findNextSchedule.addDependency(currentScheduleOperation)
        let waitOperation = WaitOperation()
        findNextSchedule.chainOperation(with: waitOperation)
        let scheduleData = ScheduleDataSend(configuration: configuration)
        scheduleData.addDependency(waitOperation)

        OperationQueue.background.addOperations(
           [findNextSchedule, waitOperation, scheduleData],
           waitUntilFinished: false)
    }

    static func cancelScheduledDataSend() {
        guard let scheduleOperations =
            OperationQueue.background.operations.filter({
                $0 is ScheduleDataSend
            }) as? [ScheduleDataSend] else { return }
        var executing: [ScheduleDataSend] = []
        var notExecuting: [ScheduleDataSend] = []
        scheduleOperations.forEach({
            if $0.isExecuting {
                executing.append($0)
            } else {
                notExecuting.append($0)
            }
        })
        executing.forEach({ $0.stopRepeating() })
        notExecuting.forEach({ $0.cancel() })
    }

    init(
        configuration: Configuration,
        repeats: Bool = true,
        sentCompletion: DataSendCompletion? = nil
    ) {
        self.configuration = configuration
        self.repeats = repeats
        self.sentCompletion = sentCompletion
    }

    func stopRepeating() {
        repeats = false
    }

    override func execute() {
        guard let context = Storage.shared?.deleteContext else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }
        guard let sessionContext = Storage.shared?.sessionContext else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        performOperations(with: context, and: sessionContext)
    }

    private func performOperations(
        with context: NSManagedObjectContext,
        and sessionContext: NSManagedObjectContext
    ) {
        let fetchOperation = FetchOperation<ItemSession>(context: context)
        let processOperation = ProcessItemSessionsOperation(
            context: context,
            sessionContext: sessionContext,
            configuration: configuration)
        fetchOperation.chainOperation(with: processOperation)
        let createOldEventsPredicate = CreateOldEventsOperation(
            configuration: configuration)
        createOldEventsPredicate.addDependency(processOperation)
        let fetchEvents = FetchOperation<TimezonedDate>(context: context)
        createOldEventsPredicate.chainOperation(with: fetchEvents)
        let deleteEvents = DeleteOperation<TimezonedDate>(context: context)
        fetchEvents.chainOperation(with: deleteEvents)
        let saveOperation = SaveContextOperation(context: context)
        saveOperation.addDependency(deleteEvents)
        let fetchServers = FetchOperation<Server>(context: context)
        fetchServers.addDependency(saveOperation)
        let sendDataOperation = SendDataOperation(
            configuration: configuration, context: context)
        fetchServers.chainOperation(with: sendDataOperation)
        let sentCompletionClosure = self.sentCompletion
        let sentCompletionOperation = ClosureInputOperation<UIBackgroundFetchResult>(
            closure: { [weak self] in
                sentCompletionClosure?($0)
                guard let strongSelf = self else { return }
                if strongSelf.repeats {
                    ScheduleDataSend.scheduleDataSend(
                        configuration: strongSelf.configuration)
                }
                strongSelf.finish()
        })
        sendDataOperation.chainOperation(with: sentCompletionOperation)

        OperationQueue.background.addOperations(
            [fetchOperation,
             processOperation,
             createOldEventsPredicate,
             fetchEvents,
             deleteEvents,
             saveOperation,
             fetchServers,
             sendDataOperation,
             sentCompletionOperation],
            waitUntilFinished: false)
    }
}
