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

        public init(chapter: Chapter) {
            self.chapter = chapter
            self.rawText = chapter.body
            self.manuscriptBody = ManuscriptBody(text: chapter.body)
        }
    }

    public enum Action: Equatable {
        case textChanged(String)
        case toggleEditorVisibility
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case bodyUpdated(Chapter)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .textChanged(text):
                state.rawText = text
                state.manuscriptBody = ManuscriptBody(text: text)
                state.chapter.body = text
                return .send(.delegate(.bodyUpdated(state.chapter)))

            case .toggleEditorVisibility:
                state.isEditorVisible.toggle()
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
