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
                    CharacterCardListView(characters: detailStore.work.characters) { character in
                        store.send(.createCharacter(character))
                    }

                case .story:
                    StoryListView(
                        work: detailStore.work,
                        onCreateChapter: { chapter in
                            store.send(.createChapter(chapter))
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
