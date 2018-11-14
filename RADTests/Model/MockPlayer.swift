//
//  MockPlayer.swift
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
@testable import RAD

class MockPlayer: AVPlayer {
    private typealias ChangeHandler = () -> Void
    override var timeControlStatus: AVPlayer.TimeControlStatus {
        if willStartPlaying {
            return .waitingToPlayAtSpecifiedRate
        } else {
            return timer != nil ? .playing : .paused
        }
    }

    private var timer: RAD.Timer?
    private var interval: TimeInterval {
        return TimeInterval.milliseconds(1)
    }
    private var timePassed: TimeInterval = 0
    private var timescale: CMTimeScale = CMTime.TimeScale.podcast
    private var willStartPlaying = false

    override func play() {
        guard currentItem != nil else { return }

        willStartPlaying = true
        changeValue(for: \MockPlayer.timeControlStatus, changeHandler: nil)
        changeValue(for: \MockPlayer.timeControlStatus) {
            self.willStartPlaying = false
            self.createTimer()
        }
    }

    override func pause() {
        changeValue(for: \MockPlayer.timeControlStatus) {
            self.stopTimer()
        }
    }

    override func replaceCurrentItem(with item: AVPlayerItem?) {
        reset()

        super.replaceCurrentItem(with: item)
    }

    override func currentTime() -> CMTime {
        return CMTime(seconds: timePassed, preferredTimescale: timescale)
    }

    override func seek(to time: CMTime) {
        timePassed = time.seconds
        NotificationCenter.default.post(
            name: .AVPlayerItemTimeJumped, object: currentItem)
    }

    // MARK: Private functionality

    private func createTimer() {
        let interval = self.interval
        timer = RAD.Timer.scheduledTimer(
            interval: interval, queue: .concurrent, closure: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.timePassed += interval
                strongSelf.checkTime()
        })
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func reset() {
        stopTimer()
        timePassed = 0
    }

    private func checkTime() {
        guard let currentItem = currentItem else { return }

        if timePassed >= currentItem.asset.duration.seconds {
            reset()
            NotificationCenter.default.post(
                name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
        }
    }

    private func changeValue<Value>(
        for keyPath: KeyPath<MockPlayer, Value>, changeHandler: ChangeHandler?
    ) {
        willChangeValue(for: keyPath)
        changeHandler?()
        didChangeValue(for: keyPath)
    }
}
