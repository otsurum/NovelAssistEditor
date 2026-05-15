import AppCore
import CharacterCardListFeature
import ComposableArchitecture
import StoryListFeature
import SwiftUI
import WorkDetailFeature

struct SelectedWorkContentView: View {
    @Bindable var store: StoreOf<WorkListFeature>
    let detailStore: StoreOf<WorkDetailFeature>

    var body: some View {
        HStack(spacing: 0) {
            WorkContentSidebar(store: store, work: detailStore.work)
                .frame(width: 188)

            Divider()

            Group {
                switch store.selectedWorkContent {
                case .general:
                    WorkDetailView(store: detailStore)

                case .characters:
                    if let childStore = store.scope(state: \.characterCardList, action: \.characterCardList) {
                        CharacterCardListView(store: childStore)
                    }

                case .story:
                    if let childStore = store.scope(state: \.storyList, action: \.storyList) {
                        StoryListView(store: childStore)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
