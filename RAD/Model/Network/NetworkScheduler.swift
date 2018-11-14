//
//  NetworkScheduler.swift
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

class NetworkScheduler {
    let configuration: Configuration
    private var appDidEnterBackgroundObservation: Any?
    private var appWillEnterForegroundObservation: Any?

    private var lastUpdate: Date {
        get {
            let dateString = UserDefaults.standard.string(
                forKey: UserDefaultsKeys.networkScheduler
            ) ?? ""
            let defaultsValue = ISO8601DateFormatter().date(from: dateString)
            return defaultsValue ?? Date.distantPast
        }
        set {
            let dateString = ISO8601DateFormatter().string(from: newValue)
            UserDefaults.standard.set(
                dateString, forKey: UserDefaultsKeys.networkScheduler)
        }
    }

    init(configuration: Configuration) {
        self.configuration = configuration

        appDidEnterBackgroundObservation =
            NotificationCenter.default.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: OperationQueue.background,
                using: { _ in
                    ScheduleDataSend.cancelScheduledDataSend()
            })
        appWillEnterForegroundObservation =
            NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: OperationQueue.background,
                using: { [weak self] _ in
                    self?.startScheduling()
            })
    }

    func startScheduling() {
        endScheduling()
        ScheduleDataSend.scheduleDataSend(configuration: configuration)
    }

    func endScheduling() {
        ScheduleDataSend.cancelScheduledDataSend()
    }

    func executeDataSent(
        with completion: @escaping ScheduleDataSend.DataSendCompletion
    ) {
        let findNextSchedule = FindNextSchedule(configuration: configuration)
        let closureOperation = ClosureInputOperation<TimeInterval> {
            if $0 > 0 {
                completion(.noData)
            } else {
                let dataSendOperation = ScheduleDataSend(
                    configuration: self.configuration,
                    repeats: false,
                    sentCompletion: completion)
                OperationQueue.background.addOperation(dataSendOperation)
            }
        }
        findNextSchedule.chainOperation(with: closureOperation)
        OperationQueue.background.addOperations(
            [findNextSchedule, closureOperation],
            waitUntilFinished: false)
    }
}
