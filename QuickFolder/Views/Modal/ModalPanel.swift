//
//  ModalWindow.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/12.
//

import AppKit

final class ModalPanel: NSPanel, NSWindowDelegate {
  var screenRect: NSRect {
    let screen = NSScreen.main
    guard let screen else { return .zero }
    return screen.visibleFrame
  }

  private var throttleDelay = 0.05
  private var lastExecution: Date = .distantPast

  var isRunning: Bool = false
  var duration = 0.1
  init(contentRect: NSRect) {
    super.init(
      contentRect: contentRect,
      styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel, .hudWindow],
      backing: .buffered,
      defer: false
    )
    hasShadow = true
    isMovable = false
    isMovableByWindowBackground = false
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    level = .floating
    collectionBehavior.insert(.fullScreenAuxiliary)
    collectionBehavior.insert(.canJoinAllSpaces)
    isReleasedWhenClosed = false
    isOpaque = false
    delegate = self
    backgroundColor = NSColor.clear
  }

  @MainActor override func animationResizeTime(_ newFrame: NSRect) -> TimeInterval {
    super.animationResizeTime(newFrame)
    return TimeInterval(0.2)
  }

  private func throttle(action: @escaping () -> Void) {
    let now = Date()
    guard now.timeIntervalSince(lastExecution) > throttleDelay else { return }
    lastExecution = now
    DispatchQueue.main.asyncAfter(deadline: .now() + throttleDelay, execute: action)
  }

//  override func mouseDragged(with event: NSEvent) {
//    super.mouseDragged(with: event)
//    throttle(action: {
//      self.setOrigin(x: event.locationInWindow.x)
//      print("Mouse dragged at location: \(event.locationInWindow.x)")
//    })
//  }

  // 显示面板时的动画
  @MainActor func showWithAnimation() {
    if isRunning { return }
    if isVisible { return }
    isRunning = true
    let panel = self

    let targetOrigin = NSPoint(
      x: screenRect.maxX - frame.width - 10,
      y: screenRect.maxY - frame.height - 10
    )
    let startOrigin = NSPoint(
      x: targetOrigin.x + frame.width / 2,
      y: targetOrigin.y
    )
    panel.setFrameOrigin(startOrigin)

//    panel.orderFront(self)
//    panel.makeKeyAndOrderFront(self)
    panel.setIsVisible(true)

    NSAnimationContext.runAnimationGroup({ context in
      context.allowsImplicitAnimation = true // frame need
      context.duration = duration
      context.timingFunction = CAMediaTimingFunction(name: .easeOut)
      panel.animator().alphaValue = 1.0
      panel.setFrameOrigin(targetOrigin)
    }, completionHandler: {
      self.contentView!.layer?.removeAllAnimations()
      self.isRunning = false
    })
  }

  @MainActor
  func hideWithAnimation(completion: (() -> Void)? = nil) {
    if isRunning { return }
    if !isVisible { return }
    isRunning = true
    let targetPoint = NSPoint(
      x: frame.origin.x + frame.width,
      y: frame.origin.y + frame.height
    )

    NSAnimationContext.runAnimationGroup({ context in
      context.allowsImplicitAnimation = true
      context.duration = duration
      context.timingFunction = CAMediaTimingFunction(name: .easeIn)
      self.animator().alphaValue = 0.0
      self.setFrameOrigin(targetPoint)
    }, completionHandler: {
      self.orderOut(self)
      self.setIsVisible(false)
      self.isRunning = false
      completion?()
    })
  }

  func setOrigin(x: CGFloat) {
    let currentFrame = frame
    let newX = currentFrame.origin.x + x
    NSAnimationContext.runAnimationGroup({ context in
      context.allowsImplicitAnimation = true
      context.duration = 1
      self.setFrameOrigin(NSPoint(x: newX, y: currentFrame.origin.y))
    }, completionHandler: {
      self.isRunning = false
    })
  }
}
