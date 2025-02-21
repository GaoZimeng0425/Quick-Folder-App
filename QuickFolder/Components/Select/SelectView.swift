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
  var onClick: ((_ newValue: Value, _ oldValue: Value) -> Void)?

  var backgroundColor: Color = .gray.opacity(0.1)
  var cornerRadius: CGFloat = 8
  var horizontalPadding: CGFloat = 10
  var verticalPadding: CGFloat = 10

  var body: some View {
    Menu {
      ForEach(options, id: \.self) { option in
        Button {
          onClick?(value, option)
          value = option
        } label: {
          HStack {
            if value == option {
              Image(systemName: "checkmark")
            }
            Text(option.label)
            Spacer(minLength: 16)
          }
        }
      }
    } label: {
      HStack {
        title
      }
      .padding(.horizontal, horizontalPadding)
      .padding(.vertical, verticalPadding)
      .background(backgroundColor)
      .cornerRadius(cornerRadius)
    }
    .menuStyle(.button)
    .buttonStyle(.plain)
    .hoverCursor()
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
  SelectView(title: Text(SortType.Kind.title), options: SortType.allCases, value: .constant(SortType.Kind), onClick: { oldValue, newValue in
    debugPrint("oldValue: \(oldValue), newValue: \(newValue)")
  })
  .background(Color.gray.opacity(0.1))
  .cornerRadius(8)
  .padding()
}
