//
//  FileInfoView.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/25.
//
import AVFoundation
import SwiftUI

struct FileInfoView: View {
  @Binding var selectedFile: [FileInfo?]
  @State private var isDoubleTapped = false
  @State private var isHover: Bool = false
  @State private var workItem: DispatchWorkItem?
  private var isSelected: Bool { selectedFile.contains(where: { $0!.id == file.id }) }
  private var isImage: Bool { FileService.isImage(path: file.url) }
  private var isVideo: Bool { FileService.isVideo(path: file.url) }

  var file: FileInfo
  var onSingleTap: ((FileInfo) -> Void)?
  var onDoubleTap: ((FileInfo) -> Void)?

  var body: some View {
    VStack {
      Spacer()
      PreviewImage(file: file)
        .padding(.all, 5)
        .background(isSelected ? .white.opacity(0.2) : .clear)
      Spacer().frame(height: 5)
      Text(file.name)
        .lineLimit(2)
        .multilineTextAlignment(.center)
        .font(.subheadline)
        .truncationMode(.middle)
        .foregroundColor(.primary)
        .padding(.horizontal, 5)
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.7) : .clear)
        .rounded(2)
      if isImage {
        let size = NSImage(contentsOf: file.url)?.size ?? .zero
        Text("\(Int(size.width)) x \(Int(size.height))")
          .font(.footnote)
          .truncationMode(.middle)
          .foregroundColor(.secondary)
      } else if !file.isDirectory {
        Text("\(FileService.sizeFormat(bytes: file.size))")
          .font(.footnote)
          .truncationMode(.middle)
          .foregroundColor(.secondary)
      }
      Spacer()
    }
    .padding(.horizontal, 5)
    .frame(height: 110)
    .frame(maxWidth: .infinity)
    .rounded(6)
    .popover(isPresented: $isHover, attachmentAnchor: .point(.leading), arrowEdge: .leading) {
      if isImage {
        PopoverImageView(url: file.url)
      } else {
        PopoverVideoView(url: file.url)
      }
    }
    .onHover { hovering in
      if hovering && (isImage || isVideo) {
        workItem = DispatchWorkItem { isHover = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: workItem!)
      } else {
        isHover = false
        workItem?.cancel()
        workItem = nil
      }
    }
    .gesture(
      TapGesture(count: 2)
        .onEnded {
          isDoubleTapped = true
          if isDoubleTapped {
            onDoubleTap?(file)
            isDoubleTapped = false
          }
        }
        .simultaneously(with: TapGesture(count: 1)
          .onEnded {
            onSingleTap?(file)
          }
        )
    )
  }
}

struct PopoverVideoView: View {
  let url: URL
  @State private var player: AVPlayer?
  @State private var size: NSSize = .init(width: 800, height: 450)

  var body: some View {
    ZStack {
      if let player {
        VideoPlayerView(player: player)
          .frame(width: size.width, height: size.height)
      }
    }
    .padding()
    .onAppear {
      Task {
        let _size = await VideoService.getVideoSize(from: url)
        size = SizeService.clacSize(_size)
      }
      player = AVPlayer(url: url)
      player?.play()
      player?.isMuted = true
    }
    .onDisappear {
      player?.pause()
      player?.seek(to: .zero)
      player = nil
    }
  }
}

struct PopoverImageView: View {
  let url: URL
  private var nsImage: NSImage? { NSImage(contentsOf: url) }
  private var adjustedSize: NSSize { SizeService.clacSize(nsImage?.size) }

  var body: some View {
    ZStack {
      if let nsImage = nsImage {
        Image(nsImage: nsImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: adjustedSize.width, height: adjustedSize.height)
      } else {
        Text("Image not available")
      }
    }
    .padding()
  }
}

struct FileInfoView_Previews: PreviewProvider {
  static var previews: some View {
    @State var previewSelectedFile: [FileInfo?] = FileStore.shared.selectedFiles
    @State var file: FileInfo = FileStore.shared.selectedFiles.first!
    return FileInfoView(selectedFile: $previewSelectedFile, file: file).padding()
  }
}
