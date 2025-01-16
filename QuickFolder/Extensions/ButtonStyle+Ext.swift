//
//  ButtonStyleExtension.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/2.
//
import SwiftUI

enum ButtonColor {
  case gray
  case accent
  case black
  var color: Color {
    switch self {
    case .gray: return Color.white.opacity(0.5)
    case .black: return Color.white.opacity(0.2)
    case .accent: return Color.accentColor
    }
  }
}

struct FixAwfulPerformanceStyle: ButtonStyle {
  var bgColor: ButtonColor = .gray
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .font(.body)
      .frame(height: 32)
      .padding(.horizontal, 10)
      .foregroundColor(configuration.isPressed ? .white.opacity(0.9) : .white)
      .background(bgColor.color.opacity(configuration.isPressed ? 0.2 : 0.5))
      .clipShape(RoundedRectangle(cornerRadius: 6.0))
  }
}

extension Button {
  func plain() -> some View {
    buttonStyle(.plain)
      .padding(10)
      .background(Color.gray.opacity(0.1))
      .rounded(8)
  }
}

struct IconButtonView: View {
  var isActive: Bool = false
  var action: (() -> Void)?
  var systemName: String
  var font: Font = .subheadline

  var body: some View {
    Button {
      action?()
    } label: {
      Image(systemName: systemName)
        .font(font)
        .frame(width: 32, height: 32)
        .background(!isActive ? .gray.opacity(0.2) : .accentColor.opacity(0.2))
        .rounded(8)
    }.buttonStyle(.plain)
  }
}

#Preview {
  IconButtonView(action: {}, systemName: "pencil.line")
    .padding()
}
