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
    private let player = AVPlayer(playerItem: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        analytics?.observePlayer(player)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        play()
    }

    private func play() {
        guard let url = Bundle.main.url(
            forResource: "SampleFile", withExtension: "mp3"
        ) else {
            return
        }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.play()
    }
}
