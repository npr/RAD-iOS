//
//  ViewController.swift
//  RAD-iOSDemo
//
//  Created by David Livadaru on 08/11/2018.
//  Copyright © 2018 NPR. All rights reserved.
//

import UIKit
import AVFoundation
import RAD

class ViewController: UIViewController {
    var analytics: Analytics?

    @IBOutlet private weak var playButton: UIButton!

    private let player = AVPlayer(playerItem: nil)
    private var didPlayToEndObservation: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        analytics?.observePlayer(player)
    }

    // MARK: Actions

    @IBAction private func playButtonDidTouch(_ sender: Any) {
        play()
        playButton.isEnabled = false
    }

    // MARK: Private functionality

    private func play() {
        guard let url = Bundle.main.url(
            forResource: "SampleFile", withExtension: "mp3"
        ) else {
            return
        }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.play()

        didPlayToEndObservation = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item, queue: .main, using: { _ in
                self.playButton.isEnabled = true
        })
    }
}
