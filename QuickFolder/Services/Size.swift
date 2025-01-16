//
//  Size.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/23.
//

import Foundation

private let IMAGE_SIZE_LIMIT: Double = 800
struct SizeService {
  static func clacSize(_ originalSize: NSSize? = .zero) -> NSSize {
    guard let size = originalSize else { return .zero }
    let width = size.width
    let height = size.height
    let scale = width / height
    if width > IMAGE_SIZE_LIMIT || height > IMAGE_SIZE_LIMIT {
      if scale > 1 {
        return NSSize(width: IMAGE_SIZE_LIMIT, height: IMAGE_SIZE_LIMIT / scale)
      } else {
        return NSSize(width: IMAGE_SIZE_LIMIT * scale, height: IMAGE_SIZE_LIMIT)
      }
    }
    return size
  }
}
