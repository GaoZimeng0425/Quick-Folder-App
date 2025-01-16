//
//  SettingsView.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/25.
//

import SwiftUI

enum Tabs: Equatable, Hashable {
  case watchNow
  case library
  case new
  case favorites
  case search
}

struct SettingsView: View {
  @EnvironmentObject var fileStore: FileStore
  @EnvironmentObject var appStore: AppStore

  func onAddDirectory() {
    if let url = QuickFolderApp.shared.appDelegate.selectDownloadsFolder() {
      let info = fileStore.addFolder(url: url)
      fileStore.selectedDirectoryId = info?.id
    }
  }

  var body: some View {
    TabView {
      VStack(alignment: .leading, spacing: 10) {
        GeneralView()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .padding()
      .tabItem {
        Label {
          Text("General")
        } icon: {
          Image(systemName: "gear")
        }
      }

      VStack {
        ShortcutView()
      }
      .padding()
      .tabItem {
        Label {
          Text("Shortcut")
        } icon: {
          Image(systemName: "keyboard")
        }
      }

      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          LibraryView()

          OperationView()
        }
        .padding()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .tabItem {
        Label {
          Text("Folder")
        } icon: {
          Image(systemName: "folder")
        }
      }
    }
  }

  @ViewBuilder
  func ShortcutView() -> some View {
    VStack {
      GroupBox {
        KeyboardQuestionView().padding(10)
      }
      Spacer()
    }
  }

  @ViewBuilder
  func GeneralView() -> some View {
    GroupBox {
      VStack(spacing: 10) {
        VStack(alignment: .leading, spacing: 5) {
          HStack {
            Text("Auto Launch")
            Spacer()
            Toggle("", isOn: $appStore.isAutoLaunchEnabled)
              .toggleStyle(.switch)
          }.padding(10)

          Divider()

          HStack {
            Text("Show Dock Icon")
            Spacer()
            Toggle("", isOn: $appStore.isDockIconVisible)
              .toggleStyle(.switch)
          }.padding(10)
        }
      }
    }
  }

  @ViewBuilder
  func LibraryView() -> some View {
    GroupBox {
      VStack(spacing: 10) {
        if fileStore.directories.isEmpty {
          HStack {
            Button {
              onAddDirectory()
            } label: {
              Text("Add Directory")
            }
            .buttonStyle(FixAwfulPerformanceStyle(bgColor: .gray))
          }.frame(maxWidth: .infinity)
        } else {
          ForEach(fileStore.directories) { directory in
            HStack {
              VStack(alignment: .leading, spacing: 5) {
                Text(directory.name)
                  .font(.system(size: 12))
                  .fontWeight(.semibold)
                Text(directory.url.relativePath)
                  .font(.caption2)
                  .foregroundStyle(.secondary)
              }

              Spacer()

              IconButtonView(action: {
                fileStore.removeFolder(directory: directory)
              }, systemName: "trash")
            }
            .padding()
            .background(.background)
          }
        }
      }
      .padding(10)
    }
  }

  @ViewBuilder
  func OperationView() -> some View {
    GroupBox {
      HStack {
        Spacer()
        Button {
          _ = QuickFolderApp.shared.appDelegate.selectDownloadsFolder()
        } label: {
          HStack {
            Image(systemName: "plus")
            Text("Add")
          }.font(.caption)
        }.plain()

        Button {
          fileStore.removeAllFolder()
        } label: {
          HStack {
            Image(systemName: "trash")
            Text("Delete All")
          }.font(.caption)
        }.plain()
      }.padding(10)
    }
  }
}

#Preview {
  SettingsView()
    .environmentObject(FileStore.shared)
    .environmentObject(AppStore.shared)
}
