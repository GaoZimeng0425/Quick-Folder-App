//
//  FileStore.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/23.
//

import FileKit
import Ifrit
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

let fuse = Fuse()

protocol Selectable: Hashable, CaseIterable {
  var title: String { get }
  var label: String { get }
}

enum SortType: String, Selectable {
  case All
  case Name
  case Kind
  case CreationDate
  case Size

  var title: String {
    switch self {
    case .All: return "Sort By"
    case .CreationDate: return "Date Created"
    default: return rawValue
    }
  }

  var label: String {
    switch self {
    case .CreationDate: return "Date Created"
    default: return rawValue
    }
  }

  func sort(_ files: [FileInfo], order: SortOrder = .reverse) -> [FileInfo] {
    switch self {
    case .Name:
      return files.sorted(using: SortDescriptor(\.name, order: order))
    case .Kind:
      return files.sorted(using: SortDescriptor(\.kind, order: order))
    case .CreationDate:
      return files.sorted(using: SortDescriptor(\.creationDate, order: order))
    case .Size:
      return files.sorted(using: SortDescriptor(\.size, order: order))
    case .All:
      return files
    }
  }
}

enum DateFilterType: String, Selectable {
  case All
  case Today
  case Yesterday
  case ThisWeek
  case LastWeek
  case ThisMonth
  case LastMonth

  var title: String {
    switch self {
    case .All: return "Date Range"
    default: return rawValue
    }
  }

  var label: String { rawValue }

  var range: (start: Date, end: Date) {
    let calendar = Calendar.current
    let now = Date()

    switch self {
    case .All:
      let startDate = calendar.date(byAdding: .year, value: -100, to: now).flatMap { calendar.startOfDay(for: $0) } ?? now
      let endDate = calendar.startOfDay(for: now).addingTimeInterval(86400 - 1)
      return (startDate, endDate)

    case .Today:
      let startDate = calendar.startOfDay(for: now)
      let endDate = startDate.addingTimeInterval(86400 - 1)
      return (startDate, endDate)

    case .Yesterday:
      let startDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)) ?? now
      let endDate = calendar.startOfDay(for: now).addingTimeInterval(-1)
      return (startDate, endDate)

    case .ThisWeek:
      let startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)).flatMap { calendar.startOfDay(for: $0) } ?? now
      let endDate = calendar.date(byAdding: .day, value: 7, to: startDate)?.addingTimeInterval(-1) ?? now
      return (startDate, endDate)

    case .LastWeek:
      let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)).flatMap { calendar.startOfDay(for: $0) } ?? now
      let startDate = calendar.date(byAdding: .day, value: -7, to: thisWeekStart) ?? now
      let endDate = thisWeekStart.addingTimeInterval(-1)
      return (startDate, endDate)

    case .ThisMonth:
      let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now)).flatMap { calendar.startOfDay(for: $0) } ?? now
      let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)?.addingTimeInterval(-1) ?? now
      return (startDate, endDate)

    case .LastMonth:
      let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)).flatMap { calendar.startOfDay(for: $0) } ?? now
      let startDate = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) ?? now
      let endDate = thisMonthStart.addingTimeInterval(-1)
      return (startDate, endDate)
    }
  }
}

enum FileFilterType: String, Selectable {
  case All
  case Folder
  case Image
  case Video
  case Document
  case Audio
  case Executable
  case Code

  var title: String {
    switch self {
    case .All: return "File Type"
    default: return rawValue
    }
  }

  var label: String { rawValue }

  var type: [UTType?]? {
    switch self {
    case .All: return nil

    case .Folder: return [.directory]

    case .Image: return [.image]

    case .Video: return [.video, .movie]

    case .Document: return [
        .text,
        .plainText,
        .pdf,
        .rtf,
        UTType(filenameExtension: "mdx"),
        UTType(filenameExtension: "md"),
        UTType(filenameExtension: "docx"),
        UTType(filenameExtension: "xlsx"),
        UTType(filenameExtension: "pptx"),
      ].compactMap { $0 }

    case .Audio: return [.audio]

    case .Executable: return [.executable, .package, .diskImage, .application]

    case .Code: return [.sourceCode, .javaScript, .swiftSource, .html, UTType(filenameExtension: "mdx"), UTType(filenameExtension: "jsx"), UTType(filenameExtension: "tsx")]
    }
  }
}

struct DirectoryInfo: Identifiable, Equatable, Hashable {
  let id: UUID = .init()
  let name: String
  let url: URL
  static func == (lhs: DirectoryInfo, rhs: DirectoryInfo) -> Bool {
    lhs.id == rhs.id
  }
}

@MainActor
class FileStore: ObservableObject {
  static let shared = FileStore()
  var files: [FileInfo] = []
  @AppStorage("directoriesString") var directoriesString: String = ""
  @Published var directories: [DirectoryInfo] = [] {
    didSet { encodeDirectories() }
  }

  @Published var isHiddenFilter: Bool = false
  @Published var selectedFiles: [FileInfo] = []
  @Published var isWindowVisible: Bool = true
  @Published var rootSelectedDirectoryID: UUID?
  var rootSelectedDirectory: DirectoryInfo? {
    directories.first { $0.id == rootSelectedDirectoryID }
  }
  @Published var currentDirectoryID: UUID?
  @Published var selectedDirecory: DirectoryInfo? {
    didSet {
      files = FileService.shared.getFiles(at: selectedDirecory?.url)
      DispatchQueue.main.async {
        self.selectedFiles = self.files.filter { $0.isHidden == self.isHiddenFilter }
      }
    }
  }

  @Published var filters: [SortType] = []

  init() {
    decodeDirectories()
    selectedDirecory = directories.first
  }

  func decodeDirectories() {
    directories = directoriesString.split(separator: ",").map {
      let url = URL(string: $0.description)!
      return DirectoryInfo(name: url.lastPathComponent, url: url)
    }
  }

  func encodeDirectories() {
    directoriesString = directories.map {
      $0.url.absoluteString
    }.joined(separator: ",")
  }

  // TODO: fix subFolder bug
  func chooseFolder(url: URL?) -> DirectoryInfo? {
    let info = directories.first { $0.url == url }
    if info != nil {
      selectedDirecory = info
    } else if let url = url {
      let info = DirectoryInfo(name: url.lastPathComponent, url: url)
      selectedDirecory = info
    }
    currentDirectoryID = selectedDirecory?.id
    return selectedDirecory
  }

  func removeFolder(directory: DirectoryInfo) {
    directories.remove(at: directories.firstIndex { $0 == directory }!)
    if selectedDirecory == directory {
      let info = chooseFolder(url: directories.first?.url)
      currentDirectoryID = info?.id
    }
  }

  func removeAllFolder() {
    directories.removeAll()
    selectedDirecory = nil
    rootSelectedDirectoryID = nil
    currentDirectoryID = nil
  }

  func addFolder(url: URL) -> DirectoryInfo? {
    if directories.contains(where: { $0.url == url }) { return nil }
    let item = DirectoryInfo(name: url.lastPathComponent, url: url)
    directories.append(item)
    return chooseFolder(url: url)
  }

  func sortFiles(by type: SortType, order: SortOrder = .reverse) {
    selectedFiles = type.sort(files, order: order)
  }

  func typeFilter(by type: FileFilterType) {
    if type.type == nil {
      selectedFiles = files
    } else {
      selectedFiles = files.filter { file in
        guard let type = type.type else { return false }
        return !type.filter { uttype in
          guard let type = uttype else { return false }
          return file.utType.conforms(to: type)
        }.isEmpty
      }
    }
  }

  func rangeFilter(by range: DateFilterType) {
    selectedFiles = files.filter { file in
      file.creationDate >= range.range.start && file.creationDate <= range.range.end
    }
  }

  func stringFilter(by name: String) {
    if name.isEmpty {
      selectedFiles = files
      return
    }
    let names = files.map { $0.name }
    let result = fuse.searchSync(name, in: names)
    selectedFiles = result.filter { $0.diffScore < 0.3 }.map { files[$0.index] }
  }
}
