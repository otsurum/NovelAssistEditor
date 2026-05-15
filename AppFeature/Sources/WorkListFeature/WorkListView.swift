import AppCore
import CharacterCardListFeature
import ComposableArchitecture
import StoryListFeature
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
                    SelectedWorkContentView(store: store, detailStore: detailStore)
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
}

