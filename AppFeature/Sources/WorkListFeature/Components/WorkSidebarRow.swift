import AppCore
import SwiftUI

struct WorkSidebarRow: View {
    let work: Work

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(work.title)
                .font(.body.weight(.semibold))
                .lineLimit(1)

            HStack(spacing: 6) {
                Text(work.updatedAt.formatted(date: .numeric, time: .omitted))
                    .fontWeight(.medium)

                if let summary = work.summary, !summary.isEmpty {
                    Text(summary)
                        .lineLimit(1)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if let styleMemo = work.styleMemo, !styleMemo.isEmpty {
                    Label(styleMemo, systemImage: "pencil")
                        .lineLimit(1)
                }

                if let theme = work.theme, !theme.isEmpty {
                    Label(theme, systemImage: "lightbulb")
                        .lineLimit(1)
                }
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
