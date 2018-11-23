//
//  AnalyticsTestCase.swift
//  RAD-iOSDemoTests
//
//  Created by David Livadaru on 21/11/2018.
//  Copyright © 2018 NPR. All rights reserved.
//

import XCTest
import AVFoundation
import RAD

class AnalyticsTestCase: XCTestCase {
    var configuration: Configuration? {
        return nil
    }

    var debugger: AnalyticsDebuggable {
        return analytics.debugger
    }

    private (set) var analytics: Analytics!
    private (set) var player: AVPlayer!

    private var placeholder: Any?

    override func setUp() {
        if let configuration = configuration {
            analytics = Analytics(configuration: configuration)
        } else {
            analytics = Analytics()
        }
        player = AVPlayer(playerItem: nil)

        analytics.observePlayer(player)
    }

    func configureTestCase() {
        let item = findAsset()
        player.replaceCurrentItem(with: item)
    }

    func findAsset() -> AVPlayerItem! {
        let fileName = "SampleFile"
        let fileExtension = "mp3"
        guard let assetUrl = Bundle.test.url(
            forResource: fileName,
            withExtension: fileExtension
        ) else {
            XCTFail("Resource (\(fileName).\(fileExtension)) is not available.")
            return nil
        }
        return AVPlayerItem(url: assetUrl)
    }

    func executePlayback() {
        player.play()

        let pauseExpectation = self.expectation(
            description: "Player did pause.")

        DispatchQueue.background.asyncAfter(
            deadline: .now() + .seconds(3.3), execute: {
                self.player.pause()
                pauseExpectation.fulfill()
                self.player.replaceCurrentItem(with: nil)
        })

        wait(for: [pauseExpectation], timeout: .seconds(15))
    }
}
