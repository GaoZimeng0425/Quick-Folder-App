//
//  MouseService.swift
//  QuickFolder
//
//  Created by GaoZimeng on 2025/1/16.
//

import AppKit
import SwiftUI

struct MouseService {
  @State var mouseLocation: CGPoint = .zero
  @State var mouseDownLocation: CGPoint = .zero

  static var shared: MouseService { return .init() }

  func getMousePosition() -> NSPoint {
    let mouseLocation = NSEvent.mouseLocation
    return mouseLocation
  }

  func getMouseDownLocation() -> NSPoint {
    NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { event in
      mouseLocation = CGPoint(x: event.absoluteX, y: event.absoluteY)
      debugPrint(mouseLocation)
    }
//    if let window = NSApp.keyWindow {
//      let windowPosition = window.convertFromScreen(NSRect(origin: NSEvent.mouseLocation, size: .zero)).origin
//      return windowPosition
//    }
    return mouseLocation
  }
}
