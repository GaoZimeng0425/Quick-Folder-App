//
//  NsWindow+Extensions.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/19.
//

import AppKit

extension NSWindowController {
  var isVisible: Bool {
    get { window!.isVisible }
    set { window!.setIsVisible(newValue) }
  }

  @MainActor func addContent(contentView: NSView) {
    window!.contentView = contentView
  }

  @MainActor func removeContent() {
    if window?.contentView != nil {
      window!.contentView = nil
    }
  }
}
