//
//  FileListView.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/18.
//

import FullDiskAccess
import SwiftUI

let SPACING: CGFloat = 10

struct FileListView: View {
  let columns = [GridItem(.adaptive(minimum: 85, maximum: 125), spacing: SPACING)]
  @EnvironmentObject var appStore: AppStore
  @EnvironmentObject var fileStore: FileStore
  @State private var selectedFile: [FileInfo?] = []
  @State private var currentDirectoryFiles: [FileInfo] = []
  @State private var subDirectories: [DirectoryInfo] = []
  @FocusState private var focusedItem: FileInfo.ID?
  @State private var isLoading: Bool = false

  var body: some View {
    VStack(spacing: 0) {
      VStack(alignment: .center, spacing: 0) {
        FileGranted {
          FileHeader(selectedDirectoryId: $fileStore.selectedDirectoryId, onDirectorySelect: onDirectorySelect, onAddDirectory: onAddDirectory)
            .background(.background)
            .environmentObject(fileStore)
            .environmentObject(appStore)
            .onAppear {
              fileStore.selectedDirectoryId = fileStore.directories.first?.id
            }

          if !subDirectories.isEmpty {
            BreadcrumbView(directories: subDirectories) { directory in
              onSubDirectoriesTap(directory)
            }
          }

          if isLoading {
            Spacer()
            LoadingView()
            Spacer()
          } else if subDirectories.isEmpty && fileStore.selectedDirectoryId != fileStore.selectedDirectory?.id {
            Spacer()
            LoadingView()
            Spacer()
          } else if fileStore.selectedFiles.isEmpty {
            Spacer()
            Button {
              onAddDirectory()
            } label: {
              Text("Add Directory")
            }
            .buttonStyle(FixAwfulPerformanceStyle(bgColor: .gray))
            Spacer()
          } else {
            FileListView()
              .onMoveCommand { destination in
                debugPrint(destination)
              }
              .contextMenu {
                Button("选项 1") {
                  print("选项 1 被点击")
                }
                Button("选项 2") {
                  print("选项 2 被点击")
                }
                Divider()
                Button("删除", role: .destructive) {
                  print("删除选项被点击")
                }
              }
          }
        }
      }
      .frame(maxHeight: .infinity)
      .onTapGesture {
        selectedFile = []
      }

      FileFooter(selectedFiles: $selectedFile).environmentObject(fileStore).environmentObject(appStore)
        .background(.background)
    }
    .frame(alignment: .top)
    .background(VisualEffectView())
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
      handleDrop(providers: providers)
    }
    .onAppear {
      currentDirectoryFiles = fileStore.selectedFiles
    }
  }

  func onAddDirectory() {
    if let url = QuickFolderApp.shared.appDelegate.selectDownloadsFolder() {
      isLoading = true
      let info = fileStore.addFolder(url: url)
      fileStore.selectedDirectoryId = info?.id
      isLoading = false
    }
  }

  func onDirectorySelect(_ directory: DirectoryInfo) {
    subDirectories.removeAll()
    fileStore.selectedDirectoryId = directory.id
    Task {
      _ = fileStore.chooseFolder(url: directory.url)
    }
  }

  func onSubDirectoriesTap(_ directory: DirectoryInfo) {
    if let i = subDirectories.firstIndex(of: directory) {
      subDirectories.removeSubrange(i + 1 ..< subDirectories.count)
      _ = fileStore.chooseFolder(url: directory.url)
    }
  }

  func singleTap(file: FileInfo) {
    selectedFile.removeAll()
    selectedFile.append(file)
  }

  func doubleTap(file: FileInfo) {
    if file.isDirectory {
      if let info = fileStore.chooseFolder(url: file.url) {
        subDirectories.append(info)
      }
    } else {
      NSWorkspace.shared.open(file.url)
    }
  }

  @ViewBuilder
  func FileListView() -> some View {
    ScrollView(showsIndicators: false) {
      LazyVGrid(columns: columns, spacing: SPACING) {
        ForEach(fileStore.selectedFiles, id: \.id) { file in
          FileInfoView(selectedFile: $selectedFile, file: file, onSingleTap: singleTap, onDoubleTap: doubleTap)
            .onKeyPress(.space) {
              debugPrint("SSSSS")
              return .handled
            }
            .focused($focusedItem, equals: file.id)
            .focusEffectDisabled()
            .contextMenu {
              Button("Info") {
                print("选项 1 被点击")
              }
              Button("选项 dkdkdk") {
                print("选项 2 被点击")
              }
              Divider()
              Button("删除", role: .destructive) {
                print("删除选项被点击")
              }
            }
            .scrollTransition { content, phase in
              content
//                .offset(y: phase.isIdentity ? 0 : 10)
                  .opacity(phase.isIdentity ? 1.0 : 0.0)
            }
        }
      }
      .scrollTargetLayout()
    }
    .contentMargins(SPACING)
  }

  private func handleDrop(providers: [NSItemProvider]) -> Bool {
    for provider in providers {
      if provider.hasItemConformingToTypeIdentifier("public.file-url") {
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
          if let data = item as? Data,
             let url = URL(dataRepresentation: data, relativeTo: nil)
          {
            DispatchQueue.main.async {
              debugPrint("url \(url)")
            }
          }
        }
      }
    }
    return true
  }
}

struct PreviewImage: View {
  var file: FileInfo
  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      ThumbnailingView(url: file.url) { nsImage in
        Image(nsImage: nsImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .cornerRadius(2)
          .frame(width: 56, height: 56)
          .clipped()
      }
      if FileService.isImage(path: file.url) || FileService.isVideo(path: file.url) {
        Text(file.extensionType.uppercased())
          .font(.system(size: 10))
          .padding(.vertical, 1)
          .padding(.horizontal, 3)
          .foregroundStyle(.black)
          .fontWeight(.bold)
          .background(Color.white)
          .rounded(4)
      }
    }
  }
}

#Preview {
  FileListView()
    .frame(width: 400, height: 600)
    .environmentObject(AppStore.shared)
    .environmentObject(FileStore.shared)
}
