import SwiftUI

struct AllWorksSidebarRow: View {
    let workCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("すべての作品")
                .font(.body.weight(.semibold))
                .lineLimit(1)

            Text("\(workCount)件の作品")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
