//
//  SelectView.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/30.
//

import SwiftUI

struct SelectView<Value: Selectable, Label: View>: View {
  var title: Label
  let options: [Value]
  @Binding var value: Value

  var body: some View {
    MenuButton(label: HStack {
      title
    }) {
      ForEach(options, id: \.self) { option in
        Button {
          value = option
        } label: {
          HStack {
            if value == option {
              Image(systemName: "checkmark")
            } else {
              Spacer()
            }
            Text(option.label)
          }
        }
      }
    }
    .buttonStyle(.plain)
  }
}

// struct CustomMenuButton<Value: Hashable, Label: View>: View {
//  let title: String
//  @Binding var selectedValue: Value
//  let options: [Value]
//  let active: (Value) -> Bool
//  let label: () -> Label
//  let optionTitle: (Value) -> String // 用于生成选项标题
//
//  var body: some View {
//    Menu {
//      ForEach(options, id: \.self) { option in
//        Button {
//          selectedValue = option
//        } label: {
//          HStack {
//            if active(option) {
//              Image(systemName: "checkmark")
//            } else {
//              Spacer()
//            }
//            Text(optionTitle(option))
//          }
//        }
//      }
//    } label: {
//      label()
//    }
//    .buttonStyle(.plain)
//  }
// }

#Preview {
//  SelectView()
}
