//
//  FileGranted.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/26.
//

import FullDiskAccess
import SwiftUI

struct FileGranted<Content: View>: View {
  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
    self.content = content
  }

  var body: some View {
    if !FullDiskAccess.isGranted {
      Button {
        FullDiskAccess.promptIfNotGranted(
          title: "Enable Full Disk Access for ",
          message: "MacSymbolicator requires Full Disk Access to search for DSYMs using Spotlight.",
          settingsButtonTitle: "Open Settings",
          skipButtonTitle: "Later",
          canBeSuppressed: false, // `true` will display a "Do not ask again." checkbox and honor it
          icon: nil
        )
      } label: {
        Text("Granted access to your disk")
      }
      .buttonStyle(FixAwfulPerformanceStyle(bgColor: .gray))
    } else {
      content()
    }
  }
}

#Preview {
  FileGranted {
    Text("Full Disk Access is granted")
  }
    .frame(width: 300, height: 200)
}
