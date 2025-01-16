//
//  MenuBarView.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/26.
//

import SwiftUI

struct MenuBarView: View {
  var appDelegate: AppDelegate = QuickFolderApp.shared.appDelegate
  @EnvironmentObject var appStore: AppStore

  init() {
//    appState.$isPinned.debounce(for: .milliseconds(100), scheduler: RunLoop.main)
//      .sink { isPinned in
//        if isPinned {
//          NSWorkspace.shared.hideOtherApplications()
//        }
//      }
  }

  var body: some View {
    VStack(alignment: .center, spacing: 10) {
      Text(Bundle.main.appName)
      Text("version: \(Bundle.main.appVersion ?? "")+\(Bundle.main.appBuild ?? 0)")
      Spacer()
      HStack {
        Button {
          appStore.toggleIsPinned()
        } label: {
          appStore.isPinned
            ? Image(systemName: "pin.circle.fill")
            : Image(systemName: "pin.slash")
        }
        .plain()
        Button {
          appStore.appVisible.toggle()
        } label: {
          Text("Toggle App Visibility")
        }
        .plain()
        Button {
          NSApp.terminate(nil)
        } label: {
          Text("Quit")
        }
        .plain()
      }
    }
    .padding(40)
    .frame(width: 300, height: 200)
  }
}

#Preview {
  MenuBarView()
    .environmentObject(AppStore.shared)
}
