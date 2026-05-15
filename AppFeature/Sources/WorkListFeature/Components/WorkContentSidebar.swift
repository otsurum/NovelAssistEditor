import AppCore
import ComposableArchitecture
import SwiftUI

#if os(macOS)
    import AppKit
#endif

struct WorkContentSidebar: View {
    @Bindable var store: StoreOf<WorkListFeature>
    let work: Work

    var body: some View {
        VStack(spacing: 0) {
            List(selection: selection) {
                Section {
                    WorkContentSidebarRow(
                        title: "一般",
                        subtitle: work.updatedAt.formatted(date: .numeric, time: .omitted),
                        systemImage: "doc.text"
                    )
                    .tag(WorkListFeature.WorkContentSelection.general)

                    WorkContentSidebarRow(
                        title: "キャラクター",
                        subtitle: "\(work.characters.count)件",
                        systemImage: "person.2"
                    )
                    .tag(WorkListFeature.WorkContentSelection.characters)

                    WorkContentSidebarRow(
                        title: "ストーリー",
                        subtitle: "\(work.story.chapters.count)件",
                        systemImage: "book.pages"
                    )
                    .tag(WorkListFeature.WorkContentSelection.story)
                } header: {
                    Text(work.title)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .background(Color.workContentSidebarBackground)
    }

    private var selection: Binding<WorkListFeature.WorkContentSelection?> {
        Binding(
            get: { store.selectedWorkContent },
            set: { store.send(.workContentSelectionChanged($0)) }
        )
    }
}

struct WorkContentSidebarRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

private extension Color {
    static var workContentSidebarBackground: Color {
        #if os(macOS)
            Color(nsColor: .underPageBackgroundColor)
        #else
            Color(.secondarySystemBackground)
        #endif
    }
}
