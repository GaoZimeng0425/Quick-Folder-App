//
//  ToastController.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/11/29.
//

import AppKit
import Combine
import SwiftUI

enum ToastVariant {
  case success
  case warning
  case error

  var color: Color {
    switch self {
    case .success: return .green
    case .warning: return .orange
    case .error: return .red
    }
  }
}

class ToastModel: ObservableObject {
  static let shared = ToastModel()
  @Published var title: String = ""
  @Published var message: String = ""
  @Published var variant: ToastVariant = .success
}

class ToastController {
  let content = NSHostingView(rootView: ToastView(model: .shared))

  func updateMessage(title: String = "", message: String = "", variant: ToastVariant = .success) {
    ToastModel.shared.title = title
    ToastModel.shared.message = message
    ToastModel.shared.variant = variant
  }
}

private let timer = Timer.publish(every: 1, tolerance: 0, on: .current, in: .common).autoconnect()

struct ToastView: View {
  @ObservedObject var model: ToastModel = .shared
  @State private var duration: Int = 10
  @State private var scale: Double = 1
  @State private var counter: Int = 0
  @State private var timerCancellable: AnyCancellable?
  @State private var runnerTimer: Timer? = nil

  func start() async {
    for await _ in model.$title.receive(on: RunLoop.main).values {
      debugPrint("title changed to \(model.title)")
    }
  }

  var body: some View {
    HStack {
      Circle()
        .fill(model.variant.color.gradient)
        .frame(width: 5, height: 5)
      VStack(alignment: .leading, spacing: 2) {
        if !model.title.isEmpty {
          Text(model.title)
            .lineLimit(1)
            .font(.headline)
            .truncationMode(.tail)
            .foregroundColor(.primary)
//            .fixedSize(horizontal: true, vertical: false)
        }
        if !model.message.isEmpty {
          Text(model.message)
            .lineLimit(1)
            .font(.subheadline)
            .truncationMode(.tail)
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            .fixedSize(horizontal: false, vertical: false)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(.vertical, 5)
    .padding(.horizontal, 20)
    //    .frame(minWidth: 120, minHeight: 20)
    .frame(width: 250, height: 50)
    .edgesIgnoringSafeArea(.all)
    .fixedSize()
    .background(model.variant.color.gradient.opacity(0.2))
    .background(VisualEffectView())
    .clipShape(.capsule)
    .onAppear {
      self.timerCancellable = timer.sink(
        receiveValue: { t in
          self.counter += 1
          if self.counter >= 10 {
            self.timerCancellable?.cancel()
          }
        })
    }
    .onChange(of: duration) { _, d in
      if duration == 0 {
        scale = 0
      }
    }
    .scaleEffect(scale)
  }
}

struct T: View {
  var body: some View {
    VStack {
      Text("Hello, SwiftUI!")
        .background(Color.blue)
    }
//    .padding(-20) // 负 padding
    .frame(maxWidth: .infinity, maxHeight: .infinity)
//    .padding()
  }
}

#Preview {
  T()
}

struct Toast_Preview: PreviewProvider {
  static var previews: some View {
    ToastView(model: ToastModel.shared)
  }
}
