//
//  ViewExtension.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/11/26.
//

import SwiftUI

extension View {
  func rounded(_ radius: CGFloat) -> some View {
    return contentShape(RoundedRectangle(cornerRadius: radius))
      .containerShape(RoundedRectangle(cornerRadius: radius))
  }

  func roundedClip(_ radius: CGFloat) -> some View {
    clipShape(RoundedRectangle(cornerRadius: radius))
  }

  func roundedBorder<S: ShapeStyle>(radius: CGFloat, color: S = .blue, lineWidth: CGFloat = 1) -> some View {
    overlay(
      RoundedRectangle(cornerRadius: radius)
        .strokeBorder(color, lineWidth: lineWidth)
    )
  }
}

#Preview("button") {
  HStack {
    Button(action: {
      print("Button tapped")
    }) {
      Text("Tap me")
        .padding()
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
//        .roundedBorder(radius: 12, color: .green.gradient, lineWidth: 5)
        .rounded(10)
    }
    .buttonStyle(.plain)
  }
  .padding()
}

#Preview("border") {
  ZStack {
    Button {
      debugPrint("Tap")
    } label: {
      Text("Tap me")
        .padding()
        .background(
          VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        )
        .rounded(12)
    }.buttonStyle(.plain)

    RoundedRectangle(cornerRadius: 100)
      .strokeBorder(.green.gradient.blendMode(.normal), lineWidth: 20)

    RoundedRectangle(cornerRadius: 100)
      .stroke(
        LinearGradient(
          gradient: Gradient(
            colors: [
              .blue,
              .red,
            ]
          ),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        lineWidth: 5
      )
  }.padding()
}
