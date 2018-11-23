//
//  DispatchQueue+Queues.swift
//  RAD-iOSDemoTests
//
//  Created by David Livadaru on 21/11/2018.
//  Copyright © 2018 NPR. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static let background = DispatchQueue(
        label: "NPR.RAD-iOSDemo.TestTarget.background",
        qos: .default, attributes: DispatchQueue.Attributes.concurrent)
}
