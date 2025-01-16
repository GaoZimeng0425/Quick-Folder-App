//
//  QuickLookPreview.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/30.
//

import Quartz
import QuickLook
import QuickLookThumbnailing
import SwiftUI

class QuickLookPreview: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
  static let shared = QuickLookPreview()

  private var previewURL: URL?

  // 设置预览的文件 URL
  func preview(_ url: URL) {
    previewURL = url
    guard let panel = QLPreviewPanel.shared() else { return }

    if !panel.isVisible {
//      panel.makeKeyAndOrderFront(nil)
    }
    panel.dataSource = self
    panel.delegate = self
    panel.reloadData()
  }

  // MARK: - QLPreviewPanelDataSource

  func numberOfPreviewItems(in _: QLPreviewPanel!) -> Int {
    return previewURL != nil ? 1 : 0
  }

  func previewPanel(_: QLPreviewPanel!, previewItemAt _: Int) -> QLPreviewItem! {
    return previewURL as QLPreviewItem?
  }

  // MARK: - QLPreviewPanelDelegate

  func previewPanel(_: QLPreviewPanel!, handle _: NSEvent!) -> Bool {
    return false
  }
}

struct ThumbnailingView<Content>: View where Content: View {
  var url: URL?
  @ViewBuilder var content: (NSImage) -> Content
  @State private var previewVisible: Bool = false
  @State private var image: NSImage?

  func snapshotPreview() async -> NSImage {
    guard let url else { return NSImage() }

      let size = CGSize(width: 64, height: 64)
      let scale = NSScreen.main?.backingScaleFactor ?? 2.0
    let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .thumbnail)

    do {
      let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
      let thumbnailSize = NSSize(width: thumbnail.cgImage.width, height: thumbnail.cgImage.height)
      return NSImage(cgImage: thumbnail.cgImage, size: thumbnailSize)
    } catch {
      return NSWorkspace.shared.icon(forFile: url.path)
    }
  }

  var body: some View {
    if image != nil {
      content(image!)
    } else {
      ProgressView()
        .onAppear {
          Task {
            self.image = await snapshotPreview()
          }
        }
    }
  }
}
