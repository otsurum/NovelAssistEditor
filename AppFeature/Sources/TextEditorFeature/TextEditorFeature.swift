import AppCore
import ComposableArchitecture
import Foundation

@Reducer
public struct TextEditorFeature {
    @ObservableState
    public struct State: Equatable {
        public var chapter: Chapter
        public var manuscriptBody: ManuscriptBody
        public var rawText: String
        public var isEditorVisible: Bool = true
        public var focusRequestID = 0

        public init(chapter: Chapter) {
            self.chapter = chapter
            rawText = chapter.body
            manuscriptBody = chapter.manuscriptBody
        }
    }

    public enum Action: Equatable {
        case autoSaveDelayFinished(Chapter)
        case close
        case focusEditor
        case save
        case textChanged(String)
        case toggleEditorVisibility
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case bodyUpdated(Chapter)
            case closeEditor
            case saveRequested(Chapter)
        }
    }

    private enum CancelID {
        case autoSave
    }

    @Dependency(\.continuousClock) var clock

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .autoSaveDelayFinished(chapter):
                return .send(.delegate(.saveRequested(chapter)))

            case .close:
                let chapter = state.chapter
                return .merge(
                    .cancel(id: CancelID.autoSave),
                    .send(.delegate(.saveRequested(chapter))),
                    .send(.delegate(.closeEditor))
                )

            case .focusEditor:
                state.isEditorVisible = true
                state.focusRequestID += 1
                return .none

            case .save:
                return .send(.delegate(.saveRequested(state.chapter)))

            case let .textChanged(text):
                state.rawText = text
                state.manuscriptBody = ManuscriptBody(text: text)
                state.chapter.body = text
                let chapter = state.chapter
                let clock = self.clock
                return .merge(
                    .send(.delegate(.bodyUpdated(chapter))),
                    .run { [clock] send in
                        try await clock.sleep(for: .milliseconds(800))
                        await send(.autoSaveDelayFinished(chapter))
                    }
                    .cancellable(id: CancelID.autoSave, cancelInFlight: true)
                )

            case .toggleEditorVisibility:
                state.isEditorVisible.toggle()
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
