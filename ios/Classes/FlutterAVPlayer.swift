//
//  FlutterAVPlayer.swift
//  flutter_to_airplay
//
//  Created by Junaid Rehmat on 22/08/2020.
//

import Foundation
import AVKit
import MediaPlayer
import Flutter
import UIKit

private func currentFlutterVC() -> FlutterViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

    if let win = scenes.flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) {
        return win.rootViewController as? FlutterViewController
    }
    return scenes.flatMap({ $0.windows }).first?.rootViewController as? FlutterViewController
}

class FlutterAVPlayer: NSObject, FlutterPlatformView {
    private var _flutterAVPlayerViewController: AVPlayerViewController

    init(frame: CGRect,
         viewIdentifier: CLongLong,
         arguments: [String: Any],
         binaryMessenger: FlutterBinaryMessenger) {

        _flutterAVPlayerViewController = AVPlayerViewController()
        super.init()

        _flutterAVPlayerViewController.viewDidLoad()

        if let urlString = arguments["url"] as? String,
           let url = URL(string: urlString) {
            let item = AVPlayerItem(url: url)
            _flutterAVPlayerViewController.player = AVPlayer(playerItem: item)

        } else if let filePath = arguments["file"] as? String {
            guard let vc = currentFlutterVC() else {
                print("flutter_to_airplay: cannot find FlutterViewController")
                return
            }
            let lookUpKey = vc.lookupKey(forAsset: filePath)
            if let path = Bundle.main.path(forResource: lookUpKey, ofType: nil) {
                let item = AVPlayerItem(url: URL(fileURLWithPath: path))
                _flutterAVPlayerViewController.player = AVPlayer(playerItem: item)
            } else {
                let item = AVPlayerItem(url: URL(fileURLWithPath: filePath))
                _flutterAVPlayerViewController.player = AVPlayer(playerItem: item)
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?._flutterAVPlayerViewController.player?.play()
        }
    }

    func view() -> UIView {
        return _flutterAVPlayerViewController.view
    }
}