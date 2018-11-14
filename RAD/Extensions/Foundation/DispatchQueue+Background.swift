//
//  DispatchQueue+Background.swift
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

extension DispatchQueue {
    static let background = DispatchQueue(
        label: "npr.rad.background.queue",
        qos: DispatchQoS.background,
        attributes: [.concurrent])

    static let playerSessions = DispatchQueue(
        label: "npr.rad.playerSessions.queue",
        qos: DispatchQoS.userInteractive,
        attributes: [.concurrent])

    static let player = DispatchQueue(
        label: "npr.rad.background.player",
        qos: DispatchQoS.userInteractive)

    static let timeRange = DispatchQueue(
        label: "npr.rad.background.timeRange",
        qos: DispatchQoS.utility)

    static let itemSession = DispatchQueue(
        label: "npr.rad.background.itemSession",
        qos: DispatchQoS.utility)
}
