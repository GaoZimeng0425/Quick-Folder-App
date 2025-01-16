//
//  FileService.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/18.
//

import FileKit
import SwiftUI
import UniformTypeIdentifiers

struct FileInfo: Identifiable {
  let id = UUID()
  let name: String
  let kind: String
  let utType: UTType
  let creationDate: Date
  let modificationDate: Date
  let lastOpenedDate: Date
  let size: Int
//  let thumbnail: NSImage?
  let url: URL
  let extensionType: String
  let isDirectory: Bool
  let isHidden: Bool
}

struct FileService {
  public static let shared = FileService()
  let fileManager = FileManager.default
  let downloadsURL = Path.userDownloads.url

  func getFile(url: URL) -> FileInfo? {
    do {
      let resourceValues = try url.resourceValues(forKeys: [.nameKey, .typeIdentifierKey, .creationDateKey, .contentModificationDateKey, .contentAccessDateKey, .fileSizeKey, .isDirectoryKey, .contentModificationDateKey, .isHiddenKey])

      let name = resourceValues.name ?? "Unknown"
      let kind = resourceValues.typeIdentifier ?? "Unknown"
      let creationDate = resourceValues.creationDate ?? Date()
      let modificationDate = resourceValues.contentModificationDate ?? Date()
      let size = resourceValues.fileSize ?? 0
      let fileExtension = url.pathExtension.isEmpty ? "Unknown" : url.pathExtension
//      let thumbnail = FileService.generateThumbnail(for: url)
      let isDirectory = resourceValues.isDirectory ?? false
      let utType = UTType(kind) ?? UTType.application
      let lastOpenedDate = resourceValues.contentAccessDate ?? Date()
      let isHidden = resourceValues.isHidden ?? false
      return FileInfo(name: name, kind: kind, utType: utType, creationDate: creationDate, modificationDate: modificationDate, lastOpenedDate: lastOpenedDate, size: size, url: url, extensionType: fileExtension, isDirectory: isDirectory, isHidden: isHidden)
    } catch {
      print("Error fetching file info: \(error)")
      return nil
    }
  }

  func getFiles(at: URL? = nil) -> [FileInfo] {
    guard let at else { return [] }
    do {
      let fileURLs = try FileManager.default.contentsOfDirectory(at: at, includingPropertiesForKeys: [.nameKey, .typeIdentifierKey, .creationDateKey, .fileSizeKey, .contentModificationDateKey])

      let files: [FileInfo] = fileURLs.compactMap { url -> FileInfo? in getFile(url: url) }
      return files
    } catch {
      print("Failed to list contents of Downloads directory: \(error)")
    }
    return []
  }
}

extension FileService {
  static func isImage(path: URL) -> Bool {
    if let type = try? path.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier,
       let utType = UTType(type)
    {
      return utType.conforms(to: .image)
    }
    return false
  }

  static func isVideo(path: URL) -> Bool {
    if let type = try? path.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier,
       let utType = UTType(type)
    {
      return utType.conforms(to: .movie) || utType.conforms(to: .video)
    }
    return false
  }
}

extension FileService {
  static func generateThumbnail(for url: URL) -> NSImage? {
    if isImage(path: url) {
      return url.snapshotPreview()
    }
    if isVideo(path: url) {
      return QuickLookService.generateVideoThumbnail(for: url)
    }

    return NSWorkspace.shared.icon(forFile: url.path)
  }
}

extension FileService {
  static func sizeFormat(bytes: Int) -> String {
    let mb = Double(bytes) / 1_048_576 // 1 MB = 1024 * 1024 bytes
    let gb = Double(bytes) / 1_073_741_824 // 1 GB = 1024 * 1024 * 1024 bytes

    if gb >= 1 {
      return String(format: "%.2f GB", gb) // 保留 2 位小数
    } else if mb >= 1 {
      return String(format: "%.2f MB", mb)
    } else {
      return String(format: "%.2f KB", Double(bytes) / 1024) // 小于 1 MB 显示为 KB
    }
  }
}

extension Array where Element == FileInfo {
  func filter(by kind: String) -> [FileInfo] {
    filter { $0.kind == kind }
  }

  func sort(by sortType: SortType) -> [FileInfo] {
    switch sortType {
    case .Name: return sorted { $0.name < $1.name }
    case .Kind: return sorted { $0.kind < $1.kind }
    case .CreationDate: return sorted { $0.creationDate < $1.creationDate }
    case .Size: return sorted { $0.size < $1.size }
    default: return sorted { $0.name < $1.name }
    }
  }
}
