//
//  ToastController.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/11/29.
//

import AppKit
import Combine
import SwiftUI

enum MessageVariant {
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

class MessageModel: ObservableObject {
  static let shared = MessageModel()
  @Published var title: String = "布局原理"
  @Published var message: String = """
  SwiftUI 的布局系统是一个两阶段的协商过程，涉及到父视图和子视图之间的交互。
  建议阶段：在这个阶段，父视图会向子视图提出一个建议尺寸。这个建议尺寸是父视图希望子视图的大小。例如，如果父视图是一个 VStack，那么它可能会向子视图提出一个具有明确高度、宽度未指定的建议尺寸。
  """
  @Published var variant: MessageVariant = .success
}

class MessageController {
  let content = NSHostingView(rootView: MessageView(model: .shared))
  func updateMessage(title: String = "", message: String = "", variant: MessageVariant = .success) {
    MessageModel.shared.title = title
    MessageModel.shared.message = message
    MessageModel.shared.variant = variant
  }
}

private let timer = Timer.publish(every: 1, tolerance: 0, on: .current, in: .common).autoconnect()

struct MessageView: View {
  @ObservedObject var model: MessageModel = .shared
  @State private var duration: Int = 10
  @State private var offsetX: Double = 0

  var body: some View {

      HStack {
        VStack(alignment: .leading, spacing: 2) {
          if !model.title.isEmpty {
            Text(model.title)
              .lineLimit(1)
              .font(.headline)
              .truncationMode(.tail)
              .foregroundColor(.primary)
          }
          Spacer().frame(height: 5)
          if !model.message.isEmpty {
            Text(model.message)
              .lineLimit(3)
              .font(.subheadline)
              .truncationMode(.tail)
              .foregroundColor(.secondary)
          }
        }
        Spacer()
        Button {
          
        } label: {
          Circle()
            .fill(.primary.opacity(0.2))
            .frame(width: 16, height: 16)
            .overlay {
              Image(systemName: "xmark")
                .font(.system(size: 8))
            }
        }.buttonStyle(.plain)
      }
      .padding(.vertical, 10)
      .padding(.leading, 20)
      .padding(.trailing, 15)
      .frame(width: 350, height: 100)
      .edgesIgnoringSafeArea(.all)
      .fixedSize()
//      .containerBackground(.thickMaterial, for: .window)
      //    .background()
      .roundedClip(20)
  }
}

struct Message_Preview: PreviewProvider {
  static var previews: some View {
    VStack {
      MessageView(model: MessageModel.shared)
        .frame(width: 400, height: 400)
    }
    .padding()
    .background(Color.blue.gradient)
  }
}
