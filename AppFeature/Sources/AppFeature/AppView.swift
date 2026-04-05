import ComposableArchitecture
import SwiftUI
import WorkListFeature

public struct AppView: View {
    let store: StoreOf<WorkListFeature>

    public init() {
        store = Store(initialState: WorkListFeature.State()) {
            WorkListFeature()
        }
    }

    public var body: some View {
        WorkListView(store: store)
    }
}
