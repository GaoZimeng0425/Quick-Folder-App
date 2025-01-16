//
//  Folder_FinderApp.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/11/9.
//
import Combine
import FullDiskAccess
import HotKey
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  private var fileSystemController: PanelController!
  private let showAppHotKey = HotKey(key: .three, modifiers: [.control])
  private var cancellables = Set<AnyCancellable>()
  private var appStore = AppStore.shared
  private var fileStore = FileStore.shared

  override init() {
    super.init()
  }

  func applicationWillTerminate(_: Notification) {
    // Clean up when the application is about to terminate
  }

  func applicationDidFinishLaunching(_: Notification) {
    showAppHotKey.keyDownHandler = { [weak self] in
      guard let self else { return }
      appStore.appVisible = !self.fileSystemController.isVisible
      debugPrint(MouseService.shared.getMousePosition())
    }

    guard (NSScreen.main?.frame.size) != nil else {
      return
    }
    insetFileWindow()
  }

  @MainActor func insetFileWindow() {
    let mainWindow: NSRect = getScreenWithMouse()?.visibleFrame ?? .zero
    let contentView = NSHostingView(rootView: FileListView().environmentObject(appStore).environmentObject(fileStore))
    fileSystemController = PanelController(contentRect: NSRect(x: 0, y: 0, width: 450, height: mainWindow.height * 0.8))
    fileSystemController.addContent(contentView: contentView)
    fileSystemController.togglePined(appStore.isPinned)

    AppStore.shared.$isPinned
      .sink { [weak self] isPinned in
        self?.fileSystemController.togglePined(isPinned)
      }
      .store(in: &cancellables)

    AppStore.shared.$appVisible
      .sink { [weak self] isVisible in
        isVisible ? self?.showWindow() : self?.hideWindow()
      }
      .store(in: &cancellables)
  }

  @MainActor func showWindow() {
    fileSystemController.showWithAnimation(
      from: MouseService.shared.getMousePosition()
    )
  }

  @MainActor func hideWindow() {
    fileSystemController.hideWithAnimation()
  }

  func selectDownloadsFolder() -> URL? {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseFiles = false
    panel.canChooseDirectories = true

    if panel.runModal() == .OK, let selectedURL = panel.url {
      return selectedURL
    }
    return nil
  }
}

func getScreenWithMouse() -> NSScreen? {
  let mouseLocation = NSEvent.mouseLocation
  let screens = NSScreen.screens
  let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
  return screenWithMouse
}
