import ComposableArchitecture
import SwiftUI
import WorkDetailFeature

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
            ToolbarItem(placement: .navigation) {
                Button {
                    toggleSidebar()
                } label: {
                    Label("サイドバー", systemImage: "sidebar.leading")
                }
            }

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
