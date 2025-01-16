//
//  FileHeader.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/24.
//

import SwiftUI

struct FileHeader: View {
  @Binding var selectedDirectoryId: UUID?
  @EnvironmentObject var fileStore: FileStore
  @EnvironmentObject var appStore: AppStore
  @State var sortBy: SortType = .All
  @State var dateBy: DateFilterType = .All
  @State var fileBy: FileFilterType = .All
  @State var searchQuery: String = ""
  @State var width: CGFloat = 0
  var onDirectorySelect: ((DirectoryInfo) -> Void)?
  var onAddDirectory: (() -> Void)?
  @FocusState private var isFocused: Bool {
    didSet {
      withAnimation {
        width = !isFocused ? 150 : 0
      }
    }
  }

  @ViewBuilder
  fileprivate func DirectoryListView() -> some View {
    HStack {
      ForEach(fileStore.directories) { directory in
        let isSelected = selectedDirectoryId == directory.id
        Button {
          onDirectorySelect?(directory)
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "folder")
              .font(.body)
              .fontWeight(.semibold)
              .foregroundColor(isSelected ? .accentColor : .primary.opacity(0.6))

            Text(directory.name)
              .font(.body)
              .foregroundColor(isSelected ? .primary : .primary.opacity(0.6))
          }
        }
        .focusable()
        .buttonStyle(FixAwfulPerformanceStyle(bgColor: isSelected ? .gray : .black))
      }
    }
  }

  func onInputCancle() {
    isFocused = false
    searchQuery = ""
  }

  @ViewBuilder
  fileprivate func SearchInputView() -> some View {
    HStack(spacing: 0) {
      Button {
        isFocused.toggle()
      } label: {
        Image(systemName: "magnifyingglass")
          .font(.body)
          .fontWeight(.semibold)
      }.frame(height: 32).frame(minWidth: 32).buttonStyle(.plain)
      TextField("Search by name", text: $searchQuery)
        .textFieldStyle(.plain)
        .focused($isFocused)
        .onSubmit {}
        .disableAutocorrection(true)
        .onChange(of: searchQuery) { _, fileName in
          debugPrint(fileName)
        }
        .onSubmit {
          onInputCancle()
        }
        .onExitCommand {
          onInputCancle()
        }
        .padding(.horizontal, 8)
        .frame(width: width)
        .frame(height: 32)
    }
    .roundedBorder(radius: 5, color: isFocused ? Color.accentColor.opacity(0.6) : .clear, lineWidth: 2)
  }

  @ViewBuilder
  fileprivate func SortFileView() -> some View {
    SelectView(
      title: HStack {
        Image(systemName: "chevron.up.chevron.down")
          .font(.body)
          .fontWeight(.semibold)
        Text(sortBy.title)
      }, options: SortType.allCases, value: $sortBy
    )
    .onChange(of: sortBy) { _, sortBy in
      fileStore.sortFiles(by: sortBy)
    }
  }

  @ViewBuilder
  fileprivate func DateFilterView() -> some View {
    SelectView(
      title: HStack {
        Image(systemName: "calendar")
          .font(.body)
          .fontWeight(.semibold)
        Text(dateBy.title)
      }, options: DateFilterType.allCases, value: $dateBy
    )
    .onChange(of: dateBy) { _, dateBy in
      fileStore.rangeFilter(by: dateBy)
    }
  }

  @ViewBuilder
  fileprivate func FileFilterView() -> some View {
    SelectView(
      title: HStack {
        Image(systemName: "document")
          .font(.body)
          .fontWeight(.semibold)
        Text(fileBy.title)
      }, options: FileFilterType.allCases, value: $fileBy
    )
    .onChange(of: fileBy) { _, fileType in
      fileStore.typeFilter(by: fileType)
    }
  }

  @ViewBuilder
  fileprivate func PickFileView() -> some View {
    HStack(spacing: 20) {
      SearchInputView()

      SortFileView()

      DateFilterView()

      FileFilterView()
    }
  }

  var body: some View {
    LazyVStack(spacing: 10) {
      HStack(spacing: 10) {
        ViewThatFits {
          DirectoryListView()
          ScrollView(.horizontal) {
            DirectoryListView()
          }
          .scrollIndicators(.hidden)
        }
        IconButtonView(action: {
          onAddDirectory?()
        }, systemName: "plus")

        Spacer()

        IconButtonView(isActive: appStore.isPinned, action: {
          appStore.isPinned.toggle()
        }, systemName: appStore.isPinned ? "pin" : "pin.slash")
          .keyboardShortcut("p", modifiers: .command)
      }
//      .contentMargins(.horizontal, 0, for: .scrollIndicators)
//      .scrollTargetBehavior(.paging)
      .frame(maxWidth: .infinity, alignment: .leading)

      HStack {
        ScrollView(.horizontal, showsIndicators: false) {
          PickFileView()
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.horizontal)
    .padding(.top)
    .padding(.bottom, 10)
  }
}

#Preview {
  FileHeader(selectedDirectoryId: .constant(FileStore.shared.directories.first?.id))
    .environmentObject(AppStore.shared)
    .environmentObject(FileStore.shared)
    .frame(width: 400)
}
