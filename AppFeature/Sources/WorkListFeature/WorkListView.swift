import ComposableArchitecture
import SwiftUI

public struct WorkListView: View {
    let store: StoreOf<WorkListFeature>

    public init(store: StoreOf<WorkListFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            WorkList(store: store)
                .navigationTitle("作品")
                .onAppear {
                    store.send(.onAppear)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            store.send(.showCreateModal)
                        } label: {
                            Label("新規作成", systemImage: "plus")
                        }
                    }

                    ToolbarItem(placement: .automatic) {
                        Button {} label: {
                            Label("再読み込み", systemImage: "arrow.clockwise")
                        }
                    }
                }
                .sheet(isPresented: .constant(store.isShowingCreateModal)) {
                    CreateWorkModal(store: store)
                        .presentationDetents([.medium, .large])
                }
        }
    }
}
