import AppCore
import SwiftUI

#if os(macOS)
    import AppKit
#endif

public struct StoryListView: View {
    let work: Work
    let onCharactersTapped: () -> Void
    let onChapterTapped: (Chapter, Int) -> Void
    let onCreateChapter: (Chapter) -> Void

    @State private var isShowingCreateModal = false
    @State private var createForm = CreateChapterFormState()

    public init(
        work: Work,
        onCharactersTapped: @escaping () -> Void = {},
        onChapterTapped: @escaping (Chapter, Int) -> Void = { _, _ in },
        onCreateChapter: @escaping (Chapter) -> Void = { _ in }
    ) {
        self.work = work
        self.onCharactersTapped = onCharactersTapped
        self.onChapterTapped = onChapterTapped
        self.onCreateChapter = onCreateChapter
    }

    public var body: some View {
        Group {
            if work.story.chapters.isEmpty {
                VStack(spacing: 14) {
                    ContentUnavailableView(
                        "エピソードがありません",
                        systemImage: "book.closed",
                        description: Text("エピソードを追加してください。")
                    )

                    Button {
                        isShowingCreateModal = true
                    } label: {
                        Label("エピソードを追加", systemImage: "plus.circle")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if !work.characters.isEmpty {
                        CharactersRow(count: work.characters.count, onTap: onCharactersTapped)
                    }

                    ForEach(Array(work.story.chapters.enumerated()), id: \.element.id) { index, chapter in
                        ChapterRow(number: index + 1, chapter: chapter) {
                            onChapterTapped(chapter, index)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(work.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.storyListBackground)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingCreateModal = true
                } label: {
                    Label("エピソードを追加", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingCreateModal) {
            CreateChapterModal(
                form: $createForm,
                onCancel: dismissModal,
                onCreate: { chapter in
                    onCreateChapter(chapter)
                    dismissModal()
                }
            )
            .presentationDetents([.medium])
        }
    }

    private func dismissModal() {
        createForm = CreateChapterFormState()
        isShowingCreateModal = false
    }
}

private struct CharactersRow: View {
    let count: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Text("登場人物")
                    .font(.body)
                    .foregroundStyle(Color.storyListLink)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.storyListBackground)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
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

private extension Color {
    static var storyListBackground: Color {
        #if os(macOS)
            Color(nsColor: .textBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
    }

    static var storyListLink: Color {
        #if os(macOS)
            Color(nsColor: .linkColor)
        #else
            Color(.link)
        #endif
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

    NavigationStack {
        StoryListView(work: work)
    }
}
