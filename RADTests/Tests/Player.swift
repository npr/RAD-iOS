//
//  Player.swift
//  RADTests
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

import AVFoundation

private class Observation {}

class Player: AVPlayer {
    private typealias Closure = () -> Void

    var scheduleOperation: Operation? {
        guard closures.count > 0 else { return nil }

        let operation = BlockOperation {
            self.closures.forEach({
                $0()
            })
        }
        operation.completionBlock = {
            self.closures.removeAll()
        }
        return operation
    }

    private var observers: [Observation] = []
    private var closures: [Closure] = []

    deinit {
        assert(observers.count == 0, "Observers have not been removed.")
    }

    override func addBoundaryTimeObserver(forTimes times: [NSValue],
                                          queue: DispatchQueue?,
                                          using block: @escaping () -> Void) -> Any {
        closures.append {
            times.forEach({
                let queue = queue ?? DispatchQueue.main
                queue.asyncAfter(deadline: .now() + $0.timeValue.seconds,
                                 execute: block)
            })
        }
        let observation = Observation()
        observers.append(observation)
        return observation
    }

    override func removeTimeObserver(_ observer: Any) {
        guard let observation = observer as? Observation else { return }
        if let index = observers.index(where: {
            $0 === observation
        }) {
            observers.remove(at: index)
        }
    }
}
