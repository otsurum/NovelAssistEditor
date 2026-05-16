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
                    WorkDetailView(
                        store: detailStore,
                        navigationTitleOverride: headerTitle
                    )

                case .characters:
                    if let childStore = store.scope(state: \.characterCardList, action: \.characterCardList) {
                        CharacterCardListView(
                            store: childStore,
                            navigationTitleOverride: headerTitle
                        )
                    }

                case .story:
                    if let childStore = store.scope(state: \.storyList, action: \.storyList) {
                        StoryListView(
                            store: childStore,
                            navigationTitleOverride: headerTitle
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.workContentHeaderSeparator)
                .frame(height: 1)
        }
    }

    private var headerTitle: String {
        "\(detailStore.work.title)　>　\(store.selectedWorkContent.title)"
    }
}

private extension WorkListFeature.WorkContentSelection {
    var title: String {
        switch self {
        case .general:
            "一般"

        case .characters:
            "キャラクター"

        case .story:
            "ストーリー"
        }
    }
}
