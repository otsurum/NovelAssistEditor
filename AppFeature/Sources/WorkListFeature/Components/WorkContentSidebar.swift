import AppCore
import ComposableArchitecture
import SwiftUI

struct WorkContentSidebar: View {
    @Bindable var store: StoreOf<WorkListFeature>
    let work: Work

    var body: some View {
        VStack(spacing: 0) {
            WorkContentSidebarHeader(work: work)

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
                    Text("内容")
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
    }

    private var selection: Binding<WorkListFeature.WorkContentSelection?> {
        Binding(
            get: { store.selectedWorkContent },
            set: { store.send(.workContentSelectionChanged($0)) }
        )
    }
}

private struct WorkContentSidebarHeader: View {
    let work: Work

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(work.title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(itemCountText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 66, alignment: .center)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var itemCountText: String {
        "3件の項目"
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
