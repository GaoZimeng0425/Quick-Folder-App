import AppKit

final class Panel: NSPanel, NSWindowDelegate {
  weak var panelDelegate: PanelController?
  init(contentRect: NSRect) {
    super.init(
      contentRect: contentRect,
      styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel, .resizable],
      backing: .buffered,
      defer: true
    )

    hasShadow = true
    isMovable = true
    isMovableByWindowBackground = false
    title = ""
    titlebarSeparatorStyle = .none
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    toolbarStyle = .unifiedCompact
    level = .floating
    collectionBehavior.insert(.fullScreenAuxiliary)
    collectionBehavior.insert(.canJoinAllSpaces)
    isReleasedWhenClosed = false
    isOpaque = false
    delegate = self
    backgroundColor = NSColor.clear
  }

  override var canBecomeKey: Bool {
    true
  }

  override var canBecomeMain: Bool {
    true
  }

  func togglePined() {
    let macOSWindowUtilsViewController = contentViewController!
    (macOSWindowUtilsViewController.view as! NSVisualEffectView).material = .contentBackground

    invalidateShadow()
    level = level == .normal ? .floating : .normal
  }

  func windowDidResignKey(_: Notification) {
    panelDelegate?.handlePinned()
  }
}

final class PanelController: NSWindowController {
  var isRunning: Bool = false
  var duration: TimeInterval = 0.1
  var isPinned: Bool = false

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(contentRect: NSRect) {
    let panel = Panel(contentRect: contentRect)
    super.init(window: panel)
    panel.panelDelegate = self
  }

  func togglePined(_ pinned: Bool? = nil) {
    isPinned = pinned ?? !isPinned
  }

  @MainActor func handlePinned() {
    if !isPinned { hideWithAnimation() }
  }

  // 显示面板时的动画
  @MainActor func showWithAnimation(from: NSPoint? = nil) {
    if isRunning { return }
    if window!.isVisible { return }
    isRunning = true
    guard let panel = window as? Panel else { return }
    guard let screen = NSScreen.main else { return }

    let screenRect = screen.visibleFrame
    let panelRect = window!.frame
    var height = panelRect.height
    if height > screenRect.height {
      height = screenRect.height
      panel.setFrame(NSRect(x: 0, y: 0, width: panelRect.width, height: height), display: false)
    }


    let targetOrigin = NSPoint(
      x: (from?.x ??  screenRect.maxX) - panelRect.width,
      y: (from?.y ?? screenRect.maxY) - height
    )
    let startOrigin = NSPoint(
      x: targetOrigin.x + 200,
//      y: targetOrigin.y - panelRect.height / 25
      y: targetOrigin.y + 200
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
      self.window!.contentView!.layer?.removeAllAnimations()
      self.isRunning = false
    })
  }

  @MainActor
  func hideWithAnimation(completion: (() -> Void)? = nil) {
    if isRunning { return }
    if !window!.isVisible { return }
    guard let panel = window as? NSPanel else { return }
    if panel.isVisible == false { return }
    isRunning = true

    let currentFrame = panel.frame
    let targetPoint = NSPoint(
      x: currentFrame.origin.x + 20,
//      y: currentFrame.origin.y - currentFrame.height / 25
      y: currentFrame.origin.y + 20
    )

    NSAnimationContext.runAnimationGroup({ context in
      context.allowsImplicitAnimation = true
      context.duration = duration
      context.timingFunction = CAMediaTimingFunction(name: .easeIn)
      panel.animator().alphaValue = 0.0
      panel.setFrameOrigin(targetPoint)
    }, completionHandler: {
//      panel.orderOut(nil)
      panel.setIsVisible(false)
      self.isRunning = false
      completion?()
    })
  }
}
