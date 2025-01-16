//
//  NSImage+Ext.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/31.
//

import Cocoa

extension NSImage {
  var pngRepresentation: Data {
    guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      return .init()
    }
    let imageRep = NSBitmapImageRep(cgImage: cgImage)
    imageRep.size = size
    return imageRep.representation(using: .png, properties: [:]) ?? .init()
  }
}
