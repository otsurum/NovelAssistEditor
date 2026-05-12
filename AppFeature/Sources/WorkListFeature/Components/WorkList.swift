//
//  WorkList.swift
//  AppFeature
//
//  Created by 鶴見駿 on 2026/04/27.
//

import AppCore
import ComposableArchitecture
import SwiftUI

public struct WorkList: View {
    let store: StoreOf<WorkListFeature>
    @State private var searchText = ""

    public init(store: StoreOf<WorkListFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: selection) {
                    AllWorksSidebarRow(workCount: store.works.count)
                        .tag(WorkListFeature.SidebarSelection.allWorks)

                    Section {
                        if filteredWorks.isEmpty {
                            Text(emptyTitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 6)
                        } else {
                            ForEach(filteredWorks) { work in
                                WorkSidebarRow(work: work)
                                    .tag(WorkListFeature.SidebarSelection.work(work.id))
                            }
                        }
                    } header: {
                        Text("作品")
                    }
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "検索")
    }

    private var selection: Binding<WorkListFeature.SidebarSelection?> {
        Binding(
            get: { store.selectedSidebarItem },
            set: { store.send(.sidebarSelectionChanged($0)) }
        )
    }

    private var filteredWorks: [Work] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.works }

        return store.works.filter { work in
            [
                work.title,
                work.summary,
                work.styleMemo,
                work.theme,
            ]
            .compactMap(\.self)
            .contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    private var emptyTitle: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "作品がありません"
            : "一致する作品がありません"
    }
}

private struct AllWorksSidebarRow: View {
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

private struct WorkSidebarRow: View {
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
