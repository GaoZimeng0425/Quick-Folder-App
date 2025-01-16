//
//  video.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/11/28.
//

import AVFoundation
import SwiftUI

enum VideoService {
  static func getVideoSize(from url: URL?) async -> CGSize {
    guard let videoURL = url else { return CGSize.zero }
    let asset = AVAsset(url: videoURL)

    do {
      let tracks = try await asset.loadTracks(withMediaType: .video)
      if let videoTrack = tracks.first {
        let videoSize = try await videoTrack.load(.naturalSize)
        return videoSize
      }
    } catch {}
    return .zero
  }
}
