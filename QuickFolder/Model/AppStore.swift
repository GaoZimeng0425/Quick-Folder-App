//
//  Store.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/11/14.
//
import LaunchAtLogin
import SwiftData
import SwiftUI

class AppStore: ObservableObject {
  static let shared = AppStore()

  @AppStorage("isDockIconVisible") var isDockIconVisibleStore: Bool = false
  @AppStorage("isPinned") var isPinnedStore: Bool = false
  @AppStorage("isAutoLaunchEnabled") var isAutoLaunchEnabledStore: Bool = false

  @Published var isDockIconVisible: Bool = false {
    didSet {
      isDockIconVisibleStore = isDockIconVisible
      updateDockIconVisibility()
    }
  }

  @Published var isAutoLaunchEnabled: Bool = false {
    didSet {
      isAutoLaunchEnabledStore = isAutoLaunchEnabled
      updateAutoLaunch()
    }
  }

  @Published var isPinned: Bool = false {
    didSet {
      isPinnedStore = isPinned
    }
  }

  @Published var appVisible: Bool = false

  init() {
    isPinned = isPinnedStore
    isDockIconVisible = isDockIconVisibleStore
    isAutoLaunchEnabled = isAutoLaunchEnabledStore

    debugPrint("isDockIconVisible: \(isDockIconVisible), isPinned: \(isPinned), isAutoLaunchEnabled: \(isAutoLaunchEnabled)")

    updateDockIconVisibility()
    updateAutoLaunch()
  }

  func updateAutoLaunch() {
    debugPrint("isAutoLaunchEnabled \(isAutoLaunchEnabled)")
    DispatchQueue.main.async {
      LaunchAtLogin.isEnabled = self.isAutoLaunchEnabled
    }
  }

  func updateDockIconVisibility() {
    debugPrint("isDockIconVisible \(isDockIconVisible)")
    DispatchQueue.main.async {
      NSApp.setActivationPolicy(self.isDockIconVisible ? .regular : .accessory)
    }
  }

  func toggleIsPinned() {
    isPinned.toggle()
  }
}
