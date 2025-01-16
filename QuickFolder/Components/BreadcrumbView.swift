import SwiftUI

struct BreadcrumbView: View {
  let directories: [DirectoryInfo]
  var onNavigate: ((DirectoryInfo) -> Void)?

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 4) {
        ForEach(Array(directories.enumerated()), id: \.offset) { index, directory in
          if index > 0 {
            Image(systemName: "chevron.right")
              .foregroundColor(.gray)
              .font(.caption)
              .padding(.horizontal, 5)
          }

          Button(action: {
            onNavigate?(directory)
          }) {
            Text(directory.name)
              .foregroundColor(.primary)
              .lineLimit(1)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(5)
    .background(Color(.windowBackgroundColor).opacity(0.5))
  }
}
