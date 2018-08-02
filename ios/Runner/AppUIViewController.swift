//
//  AppUIViewController.swift
//  Runner
//
//  Created by Bipin Vaylu on 01/08/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

import Foundation
class AppUIViewController: UIViewController {
    
    fileprivate var player = Player()
    
    // MARK: object lifecycle
    deinit {
        self.player.willMove(toParentViewController: self)
        self.player.view.removeFromSuperview()
        self.player.removeFromParentViewController()
    }
    
    // MARK: view lifecycle
    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        self.player.playerDelegate = self
//        self.player.playbackDelegate = self
//        self.player.view.frame = self.view.bounds
//
//        self.addChildViewController(self.player)
//        self.view.addSubview(self.player.view)
//        self.player.didMove(toParentViewController: self)
//
//        self.player.url = videoUrl
//
//        self.player.playbackLoops = true
//
//        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        self.player.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.player.playFromBeginning()
    }
}

// MARK: - UIGestureRecognizer
extension AppUIViewController {
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue:
            self.player.playFromBeginning()
            break
        case PlaybackState.paused.rawValue:
            self.player.playFromCurrentTime()
            break
        case PlaybackState.playing.rawValue:
            self.player.pause()
            break
        case PlaybackState.failed.rawValue:
            self.player.pause()
            break
        default:
            self.player.pause()
            break
        }
    }
    
}

// MARK: - PlayerDelegate
extension AppUIViewController:PlayerDelegate {
    
    func playerReady(_ player: Player) {
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
}

// MARK: - PlayerPlaybackDelegate
extension AppUIViewController:PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
    }
    
}
