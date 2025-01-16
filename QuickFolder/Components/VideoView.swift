//
//  VideoView.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/11/26.
//

import AVKit
import SwiftUI

struct VideoPlayerView: NSViewRepresentable {
  let player: AVPlayer

  func makeNSView(context _: Context) -> NSView {
    let view = NSView(frame: .zero)
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.videoGravity = .resizeAspect
    playerLayer.frame = view.bounds
    playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
    view.layer = playerLayer
    view.wantsLayer = true
    return view
  }

  func updateNSView(_: NSView, context _: Context) {
    // No update required
  }
}
