import AppCore
import ComposableArchitecture
import SwiftUI
import WorkDetailFeature

#if os(macOS)
import AppKit
#endif

public struct WorkListView: View {
    @Bindable var store: StoreOf<WorkListFeature>
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    public init(store: StoreOf<WorkListFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            WorkList(store: store)
                .navigationTitle("作品")
                .navigationSplitViewColumnWidth(min: 220, ideal: 280, max: 340)
        } detail: {
            Group {
                if let detailStore = store.scope(state: \.detail, action: \.detail) {
                    WorkDetailView(store: detailStore)
                } else if store.selectedSidebarItem == .allWorks {
                    AllWorksOverviewView(works: store.works) { work in
                        store.send(.workTapped(work))
                    }
                } else {
                    EmptyWorkDetailView()
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            store.send(.onAppear)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.showCreateModal)
                } label: {
                    Label("新規作成", systemImage: "square.and.pencil")
                }
            }
        }
        .sheet(
            isPresented: Binding(
                get: { store.isShowingCreateModal },
                set: { isPresented in
                    if !isPresented {
                        store.send(.hideCreateModal)
                    }
                }
            )
        ) {
            CreateWorkModal(store: store)
                .presentationDetents([.medium, .large])
        }
    }

    private func toggleSidebar() {
        withAnimation(.easeInOut(duration: 0.2)) {
            columnVisibility = columnVisibility == .detailOnly ? .all : .detailOnly
        }
    }
}

private struct AllWorksOverviewView: View {
    let works: [Work]
    let onSelect: (Work) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 24, alignment: .top)
    ]

    var body: some View {
        Group {
            if works.isEmpty {
                ContentUnavailableView(
                    "作品がありません",
                    systemImage: "book.closed",
                    description: Text("まずは作品を1つ作成してください。")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("すべての作品")
                                .font(.title2.weight(.semibold))
                                .lineLimit(1)

                            Text("\(works.count)件の作品")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        LazyVGrid(columns: columns, alignment: .leading, spacing: 30) {
                            ForEach(works) { work in
                                Button {
                                    onSelect(work)
                                } label: {
                                    WorkOverviewCard(work: work)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 26)
                }
            }
        }
        .navigationTitle("すべての作品")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.workOverviewBackground)
    }
}

private struct WorkOverviewCard: View {
    let work: Work

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.workOverviewPreviewBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text(work.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if let previewText {
                        Text(previewText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(width: 180, height: 134)

            Text(work.updatedAt.formatted(date: .numeric, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            .frame(width: 180)
        }
        .frame(width: 180, alignment: .top)
        .contentShape(Rectangle())
    }

    private var previewText: String? {
        for text in [work.summary, work.styleMemo, work.theme] {
            if let text, !text.isEmpty {
                return text
            }
        }

        return nil
    }
}

private struct EmptyWorkDetailView: View {
    var body: some View {
        ContentUnavailableView(
            "作品を選択",
            systemImage: "text.book.closed",
            description: Text("左のサイドバーから作品を選んでください。")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension Color {
    static var workOverviewBackground: Color {
        #if os(macOS)
        Color(nsColor: .textBackgroundColor)
        #else
        Color(.systemBackground)
        #endif
    }

    static var workOverviewPreviewBackground: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color(.secondarySystemBackground)
        #endif
    }
}
