//
//  TimeRangeController.swift
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

import AVFoundation

protocol TimeRangeControllerDelegate: AnyObject {
    func timeRangeController(
        _ timeRangeController: TimeRangeController,
        didCreateTimeRange timeRange: TimeRange,
        synced: Bool)
    func timeRangeControllerDidFinishCreatingRanges(
        _ timeRangeController: TimeRangeController,
        synced: Bool)
}

/// Captures ranges of playback.
class TimeRangeController: TimeRangeBoundBuilder {
    private typealias ConvertTimeCompletion = (RangeBound) -> Void

    weak var delegate: TimeRangeControllerDelegate?

    private let player: AVPlayer
    private var rangeStart: CMTime? {
        get {
            return startBound?.playerTime
        }
        set {
            startBound = createTimeRangeBound(with: newValue)
        }
    }
    private var rangeEnd: CMTime? {
        get {
            return endBound?.playerTime
        }
        set {
            endBound = createTimeRangeBound(
                with: newValue, addDateTimeInformation: false)
        }
    }

    private var startBound: TimeRangeBound?
    private var endBound: TimeRangeBound?

    private var ranges: [TimeRange] = []
    private var timeJumpedBound: TimeRangeBound?

    private var timer: Timer!
    private let interval: Double

    private var periodicTimeObservation: Any?
    private var timeControlStatusObservation: Any?
    private var itemChangedObservation: Any?
    private var itemDidPlayToEndObservation: Any?
    private var timeJumpedObservation: Any?
    private var applicationWillTerminateObservation: Any?

    private var previousTime: CMTime?

    /// Creates an instance of time range controller.
    /// It is required for AVPlayer instance to have an item set before
    /// calling the constructor.
    ///
    /// - Parameter player: The player to observe.
    init(player: AVPlayer) {
        self.player = player
        let intervalInMilliseconds =
            Measurement<UnitDuration>(value: 5, unit: .milliseconds)
        self.interval = intervalInMilliseconds.converted(to: .seconds).value

        addObservers()
        if let item = player.currentItem {
            registerObservers(for: item)
        }
    }

    // MARK: Private oservers

    private func registerObservers(for item: AVPlayerItem) {
        itemDidPlayToEndObservation = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: OperationQueue.player,
            using: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.saveRange()
                strongSelf.mergeTimeRanges()
        })
        timeJumpedObservation = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemTimeJumped,
            object: item,
            queue: OperationQueue.timeRange,
            using: { [weak self] _ in
                guard let strongSelf = self else { return }

                let currentTime = strongSelf.player.currentTime()
                if currentTime.seconds >= 1.0 {
                    strongSelf.timeJumpedBound =
                        strongSelf.createTimeRangeBound(with: currentTime)
                }
        })
    }

    // MARK: Private functionality

    private func addObservers() {
        itemChangedObservation = player.observe(
            \.currentItem,
            options: [.new],
            changeHandler: { [weak self] (_, _) in
                guard let strongSelf = self else { return }
                strongSelf.saveRange()
                strongSelf.finishRecording()
        })
        applicationWillTerminateObservation =
            NotificationCenter.default.addObserver(
                forName: UIApplication.willTerminateNotification,
                object: nil,
                queue: OperationQueue.player,
                using: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.saveRange(async: false)
                    strongSelf.finishRecording(async: false)
            })
        timeControlStatusObservation = player.observe(
            \.timeControlStatus,
            changeHandler: { [weak self] (player, _) in
                guard let strongSelf = self else { return }

                switch player.timeControlStatus {
                case .paused:
                    strongSelf.deleteTimer()
                    strongSelf.saveRange()
                    strongSelf.mergeTimeRanges()
                case .waitingToPlayAtSpecifiedRate:
                    let playerTime = player.currentTime()
                    let time = playerTime.seconds < 0 ? CMTime.zero : playerTime
                    strongSelf.rangeStart = time
                    strongSelf.previousTime = time
                    strongSelf.createTimer()
                default:
                    break
                }
        })
    }

    private func save(time: CMTime) {
        guard time.isValid else { return }
        guard time.seconds >= 0 else { return }

        let previousTime = self.previousTime
        self.previousTime = time

        guard let previous = previousTime else {
            self.rangeStart = time
            return
        }

        guard self.player.timeControlStatus == .playing else { return }

        guard previous != time else {
            return
        }

        let diff = time.seconds - previous.seconds
        if abs(diff) <= self.interval * 2 {
            self.rangeEnd = previous
        } else {
            saveRange()
            self.rangeStart = time
        }

        if timeJumpedBound != nil {
            mergeTimeRanges()
        }
    }

    private func saveRange(async: Bool = true) {
        guard let start = startBound else { return }
        guard let end = endBound else { return }
        guard start.playerTime <= end.playerTime else { return }

        DispatchQueue.timeRange.execute(block: {
            let range = TimeRange(start: start, end: end)

            self.ranges.append(range)
        }, async: async)

        startBound = nil
        endBound = nil
    }

    private func mergeTimeRanges(async: Bool = true) {
        DispatchQueue.timeRange.execute(block: {
            guard let startRange = self.ranges.first else { return }

            var lastRangeBound: TimeRangeBound?
            if let timeJumpedBound = self.timeJumpedBound,
                var index = self.ranges.index(where: {
                    return $0.end.playerTime > timeJumpedBound.playerTime
            }) {
                index = index < 1 ? 1 : index
                let rangeBeforeJump = self.ranges[index - 1]
                lastRangeBound = rangeBeforeJump.end
                self.ranges.removeFirst(index)
            } else {
                lastRangeBound = self.ranges.last?.end
                self.ranges.removeAll()
            }

            guard let endRangeBound = lastRangeBound else { return }

            if startRange.start.playerTime != endRangeBound.playerTime {
                let range = TimeRange(
                    start: startRange.start, end: endRangeBound)

                self.delegate?.timeRangeController(
                    self, didCreateTimeRange: range, synced: !async)
            }
            self.timeJumpedBound = nil
        }, async: async)
    }

    private func finishRecording(async: Bool = true) {
        mergeTimeRanges(async: async)
        DispatchQueue.timeRange.execute(block: {
            let delegate = self.delegate
            delegate?.timeRangeControllerDidFinishCreatingRanges(
                self, synced: !async)
        }, async: async)
    }

    private func createTimer() {
        timer = Timer.scheduledTimer(
            interval: self.interval,
            queue: DispatchQueue.player,
            closure: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.save(time: strongSelf.player.currentTime())
        })
    }

    private func deleteTimer() {
        timer = nil
    }
}
