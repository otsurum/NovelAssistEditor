import SwiftUI
import ComposableArchitecture
import WorkListFeature

public struct AppView: View {
    let store: StoreOf<WorkListFeature>

    public init() {
        self.store = Store(initialState: WorkListFeature.State()) {
            WorkListFeature()
        }
    }

    public var body: some View {
        WorkListView(store: store)
    }
}
