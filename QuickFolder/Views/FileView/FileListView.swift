//
//  FileListView.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/18.
//

import FullDiskAccess
import SwiftUI

let SPACING: CGFloat = 15

struct FileFrame: Equatable {
  let id: UUID
  let frame: CGRect
}

struct FileFramePreferenceKey: PreferenceKey {
  static var defaultValue: [FileFrame] = []

  static func reduce(value: inout [FileFrame], nextValue: () -> [FileFrame]) {
    value.append(contentsOf: nextValue())
  }
}

struct FileListView: View {
  let columns = [GridItem(.adaptive(minimum: 85, maximum: 125), spacing: SPACING)]
  @EnvironmentObject var appStore: AppStore
  @EnvironmentObject var fileStore: FileStore
  @State private var selectedFile: [FileInfo?] = []
  @State var searchQuery: String = ""
  @State private var currentDirectoryFiles: [FileInfo] = []
  @State private var subDirectories: [DirectoryInfo] = []
  @State private var isLoading: Bool = false
  @FocusState private var focusedItem: FileInfo.ID?
  @State private var isDragging: Bool = false
  @State private var dragStartLocation: CGPoint?
  @State private var dragCurrentLocation: CGPoint?
  @State private var fileFrames: [FileFrame] = []
  @State private var fileFramesDict: [UUID: CGRect] = [:]

  var body: some View {
    VStack(spacing: 0) {
      VStack(alignment: .center, spacing: 0) {
        FileGranted {
          FileHeader(
            onDirectorySelect: onDirectorySelect,
            onAddDirectory: onAddDirectory
          )
          .background(.background)
          .environmentObject(fileStore)
          .environmentObject(appStore)
          .onAppear {
            fileStore.rootSelectedDirectoryID = fileStore.directories.first?.id
          }

          if !subDirectories.isEmpty {
            BreadcrumbView(directories: [fileStore.rootSelectedDirectory!] + subDirectories) { directory in
              onSubDirectoriesTap(directory)
            }
          }

          if isLoading {
            Spacer()
            LoadingView()
            Spacer()
          } else if subDirectories.isEmpty && fileStore.rootSelectedDirectoryID != fileStore.selectedDirecory?.id {
            Spacer()
            LoadingView()
            Spacer()
          } else if fileStore.selectedFiles.isEmpty {
            Spacer()
            Text("No files found")
              .foregroundColor(.secondary)
            Spacer()
          } else if fileStore.directories.isEmpty {
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
        selectedFile.removeAll()
      }
      .onKeyPress(.return) {
        if !selectedFile.isEmpty {
          onReturnKeydown()
          return .handled
        }
        return .ignored
      }
      .onKeyPress(.space) {
        if !selectedFile.isEmpty {
          onSpaceKeydown()
          return .handled
        }
        return .ignored
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

  private func onReturnKeydown() {
    for file in selectedFile {
      if let file = file {
        if file.isDirectory {
          if let info = fileStore.chooseFolder(url: file.url) {
            subDirectories.append(info)
          }
        } else {
          NSWorkspace.shared.open(file.url)
        }
      }
    }
  }

  private func onSpaceKeydown() {
    for file in selectedFile {
      guard let file = file else { continue }
      // TODO: open Quick Look View
      NSWorkspace.shared.open(file.url)
    }
  }

  func onAddDirectory() {
    if let url = QuickFolderApp.shared.appDelegate.selectDownloadsFolder() {
      isLoading = true
      let info = fileStore.addFolder(url: url)
      fileStore.rootSelectedDirectoryID = info?.id
      isLoading = false
    }
  }

  func onDirectorySelect(_ directory: DirectoryInfo) {
    subDirectories.removeAll()
    fileStore.rootSelectedDirectoryID = directory.id
    Task {
      _ = fileStore.chooseFolder(url: directory.url)
    }
  }

  func onSubDirectoriesTap(_ directory: DirectoryInfo) {
    if directory.id == fileStore.currentDirectoryID {
      return
    }
    if directory.id == fileStore.rootSelectedDirectoryID {
      subDirectories.removeAll()
    } else if let i = subDirectories.firstIndex(of: directory) {
      subDirectories.removeSubrange(i + 1 ..< subDirectories.count)
    }
    _ = fileStore.chooseFolder(url: directory.url)
  }

  func singleTap(file: FileInfo) {
    if NSEvent.modifierFlags.contains(.command) {
      let index = selectedFile.firstIndex(where: { $0?.id == file.id })
      if index != nil {
        selectedFile.remove(at: index!)
      } else {
        selectedFile.append(file)
      }
    } else {
      selectedFile.removeAll()
      selectedFile.append(file)
    }
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

  func deleteFiles(files: [FileInfo]) {
    for file in files {
      do {
        try FileService.shared.trashItem(at: file.url)
        fileStore.selectedFiles.removeAll { $0.id == file.id }
      } catch {
        print("Error deleting file: \(error)")
      }
    }
  }

  @ViewBuilder
  func FileListView() -> some View {
    ZStack {
      ScrollView(showsIndicators: false) {
        LazyVGrid(columns: columns, spacing: SPACING) {
          ForEach(fileStore.selectedFiles, id: \.id) { file in
            FileInfoView(selectedFile: $selectedFile, file: file, onSingleTap: singleTap, onDoubleTap: doubleTap)
              .focused($focusedItem, equals: file.id)
              .background(
                GeometryReader { geometry in
                  Color.clear
                    .preference(
                      key: FileFramePreferenceKey.self,
                      value: [FileFrame(id: file.id, frame: geometry.frame(in: .named("ScrollView")))]
                    )
                }
              )
              .contextMenu {
                Button("Show in Finder") {
                  NSWorkspace.shared.activateFileViewerSelecting([file.url])
                }
                Button("Move to Trash", role: .destructive) {
                  deleteFiles(files: [file])
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
        .onPreferenceChange(FileFramePreferenceKey.self) { frames in
          // 只在帧发生实际变化时更新
          let newDict = Dictionary(uniqueKeysWithValues: frames.map { ($0.id, $0.frame) })
          if newDict != fileFramesDict {
            fileFramesDict = newDict
          }
        }
      }
      .contentMargins(SPACING)
      .coordinateSpace(name: "ScrollView")

      // 拖动选择层
      if isDragging {
        SelectionRectangle(start: dragStartLocation ?? .zero,
                           current: dragCurrentLocation ?? .zero)
          .foregroundColor(.accentColor.opacity(0.2))
      }
    }
    .gesture(
      DragGesture(minimumDistance: 5)
        .onChanged { value in
          isDragging = true
          if dragStartLocation == nil {
            dragStartLocation = value.startLocation
          }
          dragCurrentLocation = value.location

          // 检查每个文件项是否在选择框内
          updateSelection(value)
        }
        .onEnded { _ in
          isDragging = false
          dragStartLocation = nil
          dragCurrentLocation = nil
        }
    )
  }

  // 添加选择框视图
  struct SelectionRectangle: View {
    let start: CGPoint
    let current: CGPoint

    var body: some View {
      Path { path in
        let rect = CGRect(
          x: min(start.x, current.x),
          y: min(start.y, current.y),
          width: abs(current.x - start.x),
          height: abs(current.y - start.y)
        )
        path.addRect(rect)
      }
      .stroke(Color.accentColor, lineWidth: 1)
    }
  }

  // 添加更新选择的方法
  private func updateSelection(_ value: DragGesture.Value) {
    let selectionRect = CGRect(
      x: min(value.startLocation.x, value.location.x),
      y: min(value.startLocation.y, value.location.y),
      width: abs(value.location.x - value.startLocation.x),
      height: abs(value.location.y - value.startLocation.y)
    )

    // 如果没有按住 Command 键，清空选择
    if !NSEvent.modifierFlags.contains(.command) {
      selectedFile.removeAll()
    }

    // 使用字典快速查找和更新
    for (id, frame) in fileFramesDict {
      if selectionRect.intersects(frame) {
        let file = fileStore.selectedFiles.first(where: { $0.id == id })!
        selectedFile.append(file)
      }
    }
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
    ThumbnailingView(url: file.url) { nsImage in
      Image(nsImage: nsImage)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .cornerRadius(2)
        .frame(width: 56, height: 56)
        .clipped()
    }.overlay(alignment: .bottomTrailing) {
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
