//
//  FileFooter.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/24.
//

import SwiftUI

struct FileFooter: View {
  @EnvironmentObject var fileStore: FileStore
  @EnvironmentObject var appStore: AppStore
  @State private var showSheet = false
  @Binding var selectedFiles: [FileInfo?]
  @State var showModal: Bool = false

  var body: some View {
    HStack {
      IconButtonView(action: {
        showModal.toggle()
      }, systemName: "questionmark.circle")
        .sheet(isPresented: $showModal) {
          ModalView()
            .frame(maxWidth: 400)
        }
      Spacer()
      Text(
        selectedFiles.isEmpty ?
          "\(fileStore.selectedFiles.count) items"
          : selectedFiles.count == 1 ?
          selectedFiles.first??.name ?? "" : "selected \(selectedFiles.count) items"
      )
      .frame(maxWidth: 200)
      .lineLimit(1)
      .truncationMode(.middle)
      Spacer()

      MenuButton(label: Image(systemName: "gear")) {
        SettingsLink {
          Text("Settings")
        }
        .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button {
          NSApp.terminate(nil)
        } label: {
          Text("Quit")
        }
        .keyboardShortcut("q", modifiers: .command)
      }
      .menuButtonStyle(BorderlessButtonMenuButtonStyle())
      .frame(width: 32)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 15)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct ModalView: View {
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    KeyboardQuestionView()
      .onDisappear {
        presentationMode.wrappedValue.dismiss()
      }
      .padding()
  }
}

struct FileFooterView_Previews: PreviewProvider {
  static var previews: some View {
    @State var previewSelectedFile: [FileInfo?] = FileStore.shared.selectedFiles
    FileFooter(selectedFiles: $previewSelectedFile)
      .environmentObject(FileStore.shared)
      .environmentObject(AppStore.shared)
  }
}
