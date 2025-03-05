import AppKit

enum PanelPosition {
  case topLeft, top, topRight
  case left, center, right
  case bottomLeft, bottom, bottomRight
}

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
    isMovableByWindowBackground = true
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
  private var currentPosition: PanelPosition? = nil

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
    if !isPinned {
      Task {
        await hideWithAnimation()
      }
    }
  }

  // 显示面板时的动画
  @MainActor func showWithMousePosition(from: NSPoint? = nil) {
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

    // 计算鼠标位置相对于屏幕的比例
    let mouseX = from?.x ?? screenRect.maxX
    let mouseY = from?.y ?? screenRect.maxY
    let isLeftHalf = mouseX < screenRect.midX
    let isBottomHalf = mouseY < screenRect.midY

    // 根据鼠标位置和窗口尺寸决定最佳显示位置
    let targetOrigin: NSPoint
    let startOrigin: NSPoint

    // 水平位置调整
    let xPosition: CGFloat
    if isLeftHalf && mouseX < panelRect.width {
      // 鼠标在左侧且空间不足，显示在右侧
      xPosition = mouseX
    } else {
      // 默认显示在左侧
      xPosition = mouseX - panelRect.width
    }

    // 垂直位置调整
    let yPosition: CGFloat
    if isBottomHalf && mouseY < height {
      // 鼠标在下方且空间不足，显示在上方
      yPosition = mouseY + height
    } else {
      // 默认显示在下方
      yPosition = mouseY
    }

    targetOrigin = NSPoint(x: xPosition, y: yPosition - height)
    startOrigin = NSPoint(
      x: targetOrigin.x + (isLeftHalf ? -200 : 200),
      y: targetOrigin.y + (isBottomHalf ? -200 : 200)
    )

    // 根据鼠标位置设置当前窗口方位
    if isLeftHalf {
      if isBottomHalf {
        currentPosition = .bottomLeft
      } else {
        currentPosition = .topLeft
      }
    } else {
      if isBottomHalf {
        currentPosition = .bottomRight
      } else {
        currentPosition = .topRight
      }
    }

    panel.setFrameOrigin(startOrigin)
    panel.alphaValue = 0.0 // 设置初始透明度为0
    panel.orderFront(nil)

    NSAnimationContext.runAnimationGroup({ context in
      context.allowsImplicitAnimation = true
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
  func hideWithAnimation() async {
    if isRunning { return }
    if !window!.isVisible { return }
    guard let panel = window as? NSPanel else { return }
    if panel.isVisible == false { return }
    isRunning = true

    let currentFrame = panel.frame
    let targetPoint: NSPoint

    // 根据展开方位决定收起动画的方向
    switch currentPosition {
    case .top, .topLeft, .topRight:
      // 从上方展开的窗口，向上收起
      targetPoint = NSPoint(x: currentFrame.origin.x, y: currentFrame.origin.y + 200)
    case .bottom, .bottomLeft, .bottomRight:
      // 从下方展开的窗口，向下收起
      targetPoint = NSPoint(x: currentFrame.origin.x, y: currentFrame.origin.y - 200)
    case .left:
      // 从左侧展开的窗口，向左收起
      targetPoint = NSPoint(x: currentFrame.origin.x - 200, y: currentFrame.origin.y)
    case .right:
      // 从右侧展开的窗口，向右收起
      targetPoint = NSPoint(x: currentFrame.origin.x + 200, y: currentFrame.origin.y)
    case .center:
      // 从中心展开的窗口，缩小消失
      targetPoint = currentFrame.origin
    case .none:
      // 默认向右上角收起
      targetPoint = NSPoint(x: currentFrame.origin.x + 20, y: currentFrame.origin.y + 20)
    }

    await withCheckedContinuation { continuation in
      NSAnimationContext.runAnimationGroup({ context in
        context.allowsImplicitAnimation = true
        context.duration = duration
        context.timingFunction = CAMediaTimingFunction(name: .easeIn)
        panel.animator().alphaValue = 0.0
        panel.setFrameOrigin(targetPoint)
      }, completionHandler: {
        panel.orderOut(nil)
        self.isRunning = false
        continuation.resume()
      })
    }
  }

  @MainActor
  func showAtPosition(_ position: PanelPosition) {
    if isRunning { return }
    if window!.isVisible { return }
    isRunning = true
    currentPosition = position
    guard let panel = window as? Panel else { return }
    guard let screen = NSScreen.main else { return }

    let screenRect = screen.visibleFrame
    let panelRect = window!.frame
    var height = panelRect.height
    if height > screenRect.height {
      height = screenRect.height
      panel.setFrame(NSRect(x: 0, y: 0, width: panelRect.width, height: height), display: false)
    }

    let width = panelRect.width
    debugPrint(width, "width", height, "height")
    let padding: CGFloat = 20

    // 计算目标位置
    var targetX: CGFloat
    var targetY: CGFloat

    switch position {
    case .topLeft:
      targetX = screenRect.minX + padding
      targetY = screenRect.maxY - height - padding
    case .top:
      targetX = screenRect.midX - width / 2
      targetY = screenRect.maxY - height - padding
    case .topRight:
      targetX = screenRect.maxX - width - padding
      targetY = screenRect.maxY - height - padding
    case .left:
      targetX = screenRect.minX + padding
      targetY = screenRect.midY - height / 2
    case .center:
      targetX = screenRect.midX - width / 2
      targetY = screenRect.midY - height / 2
    case .right:
      targetX = screenRect.maxX - width - padding
      targetY = screenRect.midY - height / 2
    case .bottomLeft:
      targetX = screenRect.minX + padding
      targetY = screenRect.minY + padding
    case .bottom:
      targetX = screenRect.midX - width / 2
      targetY = screenRect.minY + padding
    case .bottomRight:
      targetX = screenRect.maxX - width - padding
      targetY = screenRect.minY + padding
    }

    let targetOrigin = NSPoint(x: targetX, y: targetY)

    // 根据位置计算动画起始点，使动画方向与位置名称一致
    let startOrigin: NSPoint
    switch position {
    case .top, .topLeft, .topRight:
      // 从上方出现，动画从上到下
      startOrigin = NSPoint(x: targetX, y: targetY + 200)
    case .bottom, .bottomLeft, .bottomRight:
      // 从下方出现，动画从下到上
      startOrigin = NSPoint(x: targetX, y: targetY - 200)
    case .left:
      // 从左侧出现，动画从左到右
      startOrigin = NSPoint(x: targetX - 200, y: targetY)
    case .right:
      // 从右侧出现，动画从右到左
      startOrigin = NSPoint(x: targetX + 200, y: targetY)
    case .center:
      // 从中心扩散
      startOrigin = NSPoint(x: targetX, y: targetY)
    }

    panel.setFrameOrigin(startOrigin)
    panel.orderFront(nil)

    NSAnimationContext.runAnimationGroup({ context in
      context.allowsImplicitAnimation = true
      context.duration = duration
      context.timingFunction = CAMediaTimingFunction(name: .easeOut)
      panel.animator().alphaValue = 1.0
      panel.setFrameOrigin(targetOrigin)
    }, completionHandler: {
      self.window!.contentView!.layer?.removeAllAnimations()
      self.isRunning = false
    })
  }
}
