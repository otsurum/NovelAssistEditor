import AppCore
import ComposableArchitecture
import SwiftUI

#if os(macOS)
    import AppKit
#endif

struct WorkDetailContent: View {
    let store: StoreOf<WorkDetailFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(store.work.title)
                        .font(.largeTitle.weight(.bold))
                        .lineLimit(nil)

                    Text("更新日 \(store.work.updatedAt.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 4)

                if isBodyEmpty {
                    Text("この作品にはまだメモがありません。")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if let summary = store.work.summary, !summary.isEmpty {
                    DetailSection(title: "概要", bodyText: summary)
                }

                if let styleMemo = store.work.styleMemo, !styleMemo.isEmpty {
                    DetailSection(title: "スタイルメモ", bodyText: styleMemo)
                }

                if let theme = store.work.theme, !theme.isEmpty {
                    DetailSection(title: "テーマ", bodyText: theme)
                }

                Spacer()
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.vertical, 32)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.startEditing)
                } label: {
                    Label("編集", systemImage: "pencil")
                }
            }
        }
    }

    private var isBodyEmpty: Bool {
        [store.work.summary, store.work.styleMemo, store.work.theme]
            .compactMap(\.self)
            .allSatisfy(\.isEmpty)
    }
}

struct DetailSection: View {
    let title: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(bodyText)
                .font(.body)
                .lineSpacing(4)
                .lineLimit(nil)
        }
    }
}

extension Color {
    static var workDetailBackground: Color {
        #if os(macOS)
            Color(nsColor: .textBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
    }
}
