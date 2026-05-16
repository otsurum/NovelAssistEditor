import AppCore
import ComposableArchitecture
import SwiftUI

#if os(macOS)
    import AppKit
#endif

public struct WorkDetailView: View {
    let store: StoreOf<WorkDetailFeature>
    let navigationTitleOverride: String?

    public init(
        store: StoreOf<WorkDetailFeature>,
        navigationTitleOverride: String? = nil
    ) {
        self.store = store
        self.navigationTitleOverride = navigationTitleOverride
    }

    public var body: some View {
        Group {
            if store.isEditing {
                EditWorkForm(store: store)
            } else {
                WorkDetailContent(store: store)
            }
        }
        .navigationTitle(navigationTitleOverride ?? store.work.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.workDetailBackground)
    }
}

#Preview {
    let sampleWork = Work(
        title: "サンプル作品",
        summary: "これはサンプルの概要です",
        styleMemo: "写実的な描写を心がける",
        theme: "成長と自己発見"
    )

    let store = Store(
        initialState: WorkDetailFeature.State(work: sampleWork),
        reducer: { WorkDetailFeature() }
    )

    WorkDetailView(store: store)
}
