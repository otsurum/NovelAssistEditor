import AppCore
import ComposableArchitecture
import Foundation

@Reducer
public struct StoryListFeature {
    @ObservableState
    public struct State: Equatable {
        public var work: Work
        public var isShowingCreateModal = false
        public var createForm = CreateChapterFormState()

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
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case chapterCreated(Chapter)
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

            case .chapterTapped:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
