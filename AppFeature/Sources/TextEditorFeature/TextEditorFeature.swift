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
        case textEditingCommitted(String)
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

            case let .textEditingCommitted(text):
                let didChange = updateText(text, in: &state)
                let chapter = state.chapter
                var effects: [Effect<Action>] = [
                    .cancel(id: CancelID.autoSave),
                ]

                if didChange {
                    effects.append(.send(.delegate(.bodyUpdated(chapter))))
                }
                effects.append(.send(.delegate(.saveRequested(chapter))))

                return .concatenate(effects)

            case let .textChanged(text):
                guard updateText(text, in: &state) else {
                    return .none
                }
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

    private func updateText(_ text: String, in state: inout State) -> Bool {
        guard state.rawText != text else { return false }

        state.rawText = text
        state.manuscriptBody = state.manuscriptBody.replacingText(text)
        state.chapter.body = text
        return true
    }
}
