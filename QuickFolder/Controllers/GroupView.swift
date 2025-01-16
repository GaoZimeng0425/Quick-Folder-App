//
//  GroupView.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/3.
//

import SwiftUI

extension CustomButton {
  enum ActionOption: CaseIterable {
    case disableButton
    case showProgressView
  }
}

struct CustomButton<Label: View>: View {
  var action: () async -> Void
  var options = Set(ActionOption.allCases)
  @ViewBuilder var label: () -> Label
  @State private var isDisabled = false
  @State private var showProgressView = true

  var backgroundColor: Color?
  var foregroundColor: Color?

  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    Button(action: {
      if options.contains(.disableButton) {
        isDisabled = true
      }
      if options.contains(.showProgressView) {
        showProgressView = true
      }
      Task {
        await action()
        showProgressView = false
        isDisabled = false
      }
    }, label: {
      HStack(spacing: 10) {
        if showProgressView {
          ProgressView().frame(width: 2, height: 2)
        }
        label()
      }
    })
    .buttonStyle(.plain)
    .disabled(isDisabled)
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(backgroundColor ?? .primary)
    .foregroundColor(foregroundColor ?? (colorScheme == .dark ? .black : .white))
    .cornerRadius(8)
  }
}

struct CustomButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      CustomButton(action: {
        print("Button tapped!")
      }, label: { Text("Button").bold() })
    }.padding()
  }
}
