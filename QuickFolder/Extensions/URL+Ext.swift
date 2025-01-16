//
//  URL+Ext.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/31.
//

import Cocoa
import Foundation
import QuickLook

extension URL {
//  func snapshotPreview() async -> NSImage {
//    let thumbnailSize = CGSize(width: 64, height: 64)
//    let request = QLThumbnailGenerator.Request(fileAt: self, size: thumbnailSize, scale: 1, representationTypes: .thumbnail)
//
//    do {
//      let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
//      return NSImage(cgImage: thumbnail.cgImage, size: .zero)
//    } catch {
//      return NSWorkspace.shared.icon(forFile: path)
//    }
//  }

  func snapshotPreview() -> NSImage {
    if let preview = QLThumbnailImageCreate(
      kCFAllocatorDefault,
      self as CFURL,
      CGSize(width: 64, height: 64),
      nil
    )?.takeRetainedValue() {
      return NSImage(cgImage: preview, size: .zero)
    }
    return NSWorkspace.shared.icon(forFile: path)
  }
}
