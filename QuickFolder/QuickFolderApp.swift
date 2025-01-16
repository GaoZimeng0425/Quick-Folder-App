//
//  QuickFolderApp.swift
//  QuickFolder
//
//  Created by GaoZimeng on 2025/1/3.
//

import SwiftData
import SwiftUI

@main
struct QuickFolderApp: App {
  @StateObject var store: AppStore = .shared
  static var shared: QuickFolderApp!
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  init() {
    QuickFolderApp.shared = self
  }

  var body: some Scene {
    MenuBarExtra(Bundle.main.appName, systemImage: "magnifyingglass") {
      MenuBarView().environmentObject(store)
    }
    .menuBarExtraStyle(.window)

    Settings {
      SettingsView()
        .frame(width: 800, height: 500)
        .environmentObject(store).environmentObject(FileStore.shared)
    }
    .windowResizability(.contentSize)
    .defaultPosition(.center)
  }
}
