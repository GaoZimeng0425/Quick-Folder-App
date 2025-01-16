//
//  LoadingView.swift
//  QuickFolder
//
//  Created by GaoZimeng on 2025/1/8.
//

import SwiftUI

struct LoadingView: View {
  var body: some View {
    ProgressView()
      .progressViewStyle(.linear)
      .frame(width: 50, height: 10)
      .tint(.green)
  }
}

struct LoadingCircularView: View {
  @State private var isAnimating = false
  var color: Color = .green
  var progress: CGFloat = 0.5
  var lineWidth: CGFloat = 10
  var lineCap: CGLineCap = .round
  var size: CGFloat = 40

  var body: some View {
    ZStack {
      Circle()
        .stroke(.gray.opacity(0.25), style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))

      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          color,
          style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap)
        )
        .rotationEffect(Angle(degrees: -90))
        .rotationEffect(isAnimating ? Angle(degrees: 360) : Angle(degrees: 0))
        .animation(
          .linear(duration: 2).repeatForever(autoreverses: false),
//          .easeInOut(duration: 2).repeatForever(autoreverses: false),
          value: isAnimating
        )
    }
    .frame(width: size, height: size)
    .padding()
  }
}

#Preview("Loading View") {
  VStack {
    LoadingCircularView(lineWidth: 5, size: 20)
    LoadingView()
  }
//  .background(.gray)
}
