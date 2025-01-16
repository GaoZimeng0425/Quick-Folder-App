//
//  KeyboardQuestion.swift
//  QuickFolder
//
//  Created by GaoZimeng on 2025/1/15.
//

import SwiftUI

struct KeyboardQuestion: View {
  var title: String = ""
  var keyboardKey: [String] = []
  var body: some View {
    HStack {
      Text(title)
      Spacer()
      ForEach(keyboardKey.indices, id: \.self) { index in
        Text("\(keyboardKey[index])")
          .font(.subheadline)
          .frame(width: 32, height: 32)
          .background(.gray.opacity(0.2))
          .rounded(8)
        if index < keyboardKey.count - 1 {
          Text("+")
        }
      }
    }
  }
}

struct KeyboardQuestionView: View {
  var body: some View {
    VStack {
      KeyboardQuestion(
        title: "Toggle Quick Folder Visible",
        keyboardKey: ["⌘", "3"]
      )
      .padding(2)
      Divider()
      KeyboardQuestion(
        title: "Pin to Home Screen",
        keyboardKey: ["⌘", "P"]
      )
      .padding(2)
      Divider()
      KeyboardQuestion(
        title: "Move Tab to Front",
        keyboardKey: ["⌘", "["]
      )
      .padding(2)
      Divider()
      KeyboardQuestion(
        title: "Move Tab to Next",
        keyboardKey: ["⌘", "]"]
      )
      .padding(2)
    }
  }
}

#Preview {
  KeyboardQuestionView()
}
