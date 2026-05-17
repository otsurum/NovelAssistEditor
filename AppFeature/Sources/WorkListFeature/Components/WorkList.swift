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
