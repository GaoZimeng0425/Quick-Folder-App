//
//  QuickLookService.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/18.
//
import AppKit
import AVFoundation
import QuickLookThumbnailing

enum QuickLookService {
  static func generateThumbnailRepresentations(url: URL) -> NSImage? {
    let size = CGSize(width: 100, height: 100)
    let scale = NSScreen.main?.backingScaleFactor ?? 2.0
    let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .icon)

    var thumbnailImage: NSImage?
    let semaphore = DispatchSemaphore(value: 0)

    QLThumbnailGenerator.shared.generateRepresentations(for: request) { thumbnail, _, _ in
      if let thumbnail = thumbnail {
        thumbnailImage = NSImage(cgImage: thumbnail.cgImage, size: size)
      }
      semaphore.signal()
    }

    _ = semaphore.wait(timeout: .now() + 5)
    return thumbnailImage
  }

  static func generateVideoThumbnail(for url: URL, at time: CMTime = CMTime(seconds: 1, preferredTimescale: 600)) -> NSImage? {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true // 确保生成的缩略图方向正确

    do {
      let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      return NSImage(cgImage: cgImage, size: .zero)
    } catch {
      print("Error generating thumbnail: \(error.localizedDescription)")
      return nil
    }
  }

  static func generateThumbnailAsync(for url: URL, at time: CMTime = CMTime(seconds: 1, preferredTimescale: 600), completion: @escaping (NSImage?) -> Void) {
    DispatchQueue.global().async {
      let thumbnail = QuickLookService.generateVideoThumbnail(for: url, at: time)
      DispatchQueue.main.async {
        completion(thumbnail)
      }
    }
  }
}
