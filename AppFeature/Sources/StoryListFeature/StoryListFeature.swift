import AppCore
import ComposableArchitecture
import Foundation
import TextEditorFeature

@Reducer
public struct StoryListFeature {
    @ObservableState
    public struct State: Equatable {
        public var work: Work
        public var isShowingCreateModal = false
        public var createForm = CreateChapterFormState()
        public var textEditor: TextEditorFeature.State?

        public init(work: Work) {
            self.work = work
        }
    }

    public enum Action: Equatable {
        case showCreateModal
        case hideCreateModal
        case updateCreateFormTitle(String)
        case submitCreate
        case chapterTapped(Chapter.ID)
        case textEditor(TextEditorFeature.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case chapterCreated(Chapter)
            case chapterBodyUpdated(Chapter)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showCreateModal:
                state.isShowingCreateModal = true
                return .none

            case .hideCreateModal:
                state.isShowingCreateModal = false
                state.createForm = CreateChapterFormState()
                return .none

            case let .updateCreateFormTitle(title):
                state.createForm.episodeTitle = title
                return .none

            case .submitCreate:
                let chapter = Chapter(
                    episodeTitle: state.createForm.episodeTitle
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                )
                state.isShowingCreateModal = false
                state.createForm = CreateChapterFormState()
                return .send(.delegate(.chapterCreated(chapter)))

            case let .chapterTapped(chapterID):
                guard let chapter = state.work.story.chapters.first(where: { $0.id == chapterID }) else {
                    return .none
                }
                state.textEditor = TextEditorFeature.State(chapter: chapter)
                return .none

            case let .textEditor(.delegate(.bodyUpdated(chapter))):
                if let index = state.work.story.chapters.firstIndex(where: { $0.id == chapter.id }) {
                    state.work.story.chapters[index] = chapter
                }
                return .send(.delegate(.chapterBodyUpdated(chapter)))

            case .textEditor(.delegate(.closeEditor)):
                state.textEditor = nil
                return .none

            case .textEditor:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.textEditor, action: \.textEditor) {
            TextEditorFeature()
        }
    }
}
