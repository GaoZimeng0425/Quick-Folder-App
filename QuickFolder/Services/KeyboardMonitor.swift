//
//  KeyboardMonitor.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/11.
//

import AppKit
import Cocoa
import EventKit
import Foundation
import HotKey
import SwiftUI

class KeyboardMonitor: NSObject {
  private let rHotKey = HotKey(key: .r, modifiers: [.command, .option])
  private let gHotKey = HotKey(key: .g, modifiers: [.command, .control])
  override init() {
    super.init()
    NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
      // 在这里处理键盘按下事件
      print("全局键盘按下事件：\(event.keyCode)")
    }
  }

  func registerHotKey(active: @escaping () -> Void) {
    rHotKey.keyDownHandler = active
//    gHotKey.keyDownHandler = { [weak self] in
//      guard let self else { return }
//      if self.controller.isVisible {
//        self.hideWindow()
//      } else {
//        self.inneShow()
//      }
//    }
  }
}
