import AppCore
import Extension
import ComposableArchitecture
import SwiftUI

public struct StoryListView: View {
    @Bindable var store: StoreOf<StoryListFeature>
    let navigationTitleOverride: String?

    public init(
        store: StoreOf<StoryListFeature>,
        navigationTitleOverride: String? = nil
    ) {
        self.store = store
        self.navigationTitleOverride = navigationTitleOverride
    }

    public var body: some View {
        Group {
            if store.work.story.chapters.isEmpty {
                VStack(spacing: 14) {
                    ContentUnavailableView(
                        "エピソードがありません",
                        systemImage: "book.closed",
                        description: Text("エピソードを追加してください。")
                    )

                    Button {
                        store.send(.showCreateModal)
                    } label: {
                        Label("エピソードを追加", systemImage: "plus.circle")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(store.work.story.chapters.enumerated()), id: \.element.id) { index, chapter in
                        ChapterRow(number: index + 1, chapter: chapter) {
                            store.send(.chapterTapped(chapter.id))
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(navigationTitleOverride ?? store.work.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.storyListBackground)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.showCreateModal)
                } label: {
                    Label("エピソードを追加", systemImage: "plus")
                }
            }
        }
        .sheet(
            isPresented: Binding(
                get: { store.isShowingCreateModal },
                set: { isPresented in
                    if !isPresented { store.send(.hideCreateModal) }
                }
            )
        ) {
            CreateChapterModal(store: store)
                .presentationDetents([.medium])
        }
    }
}

private struct ChapterRow: View {
    let number: Int
    let chapter: Chapter
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Text(formattedTitle)
                    .font(.body)
                    .foregroundStyle(Color.storyListLink)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.storyListBackground)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }

    private var formattedTitle: String {
        let paddedNumber = String(format: "%02d", number)
        return "\(paddedNumber).\u{2003}\(chapter.episodeTitle)"
    }
}

#Preview {
    let work = Work(
        title: "魔導師ダリィの逃亡",
        characters: [
            Character(name: "ダリィ", personality: "冷静沈着"),
            Character(name: "騎士団長", background: "元帝国軍人"),
        ],
        story: Story(chapters: [
            Chapter(episodeTitle: "新居で婚約破棄"),
            Chapter(episodeTitle: "友人への報告"),
            Chapter(episodeTitle: "商業ギルド"),
            Chapter(episodeTitle: "婚約破棄の清算"),
            Chapter(episodeTitle: "新居での発見"),
            Chapter(episodeTitle: "緑の塔"),
            Chapter(episodeTitle: "最悪の目覚め"),
            Chapter(episodeTitle: "髪を切る"),
        ])
    )

    let store = Store(
        initialState: StoryListFeature.State(work: work),
        reducer: { StoryListFeature() }
    )

    NavigationStack {
        StoryListView(store: store)
    }
}
