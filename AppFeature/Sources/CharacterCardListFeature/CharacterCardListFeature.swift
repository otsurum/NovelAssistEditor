import AppCore
import CharacterDetailFeature
import ComposableArchitecture
import Extension
import Foundation

@Reducer
public struct CharacterCardListFeature {
    @ObservableState
    public struct State: Equatable {
        public var characters: [AppCore.Character]
        public var isShowingCreateModal = false
        public var createForm = CreateCharacterFormState()
        public var detail: CharacterDetailFeature.State?

        public init(characters: [AppCore.Character]) {
            self.characters = characters
        }
    }

    public enum Action: Equatable {
        case detail(CharacterDetailFeature.Action)
        case showCreateModal
        case hideCreateModal
        case updateCreateFormName(String)
        case updateCreateFormPersonality(String)
        case updateCreateFormSpeechStyle(String)
        case updateCreateFormBackground(String)
        case submitCreate
        case characterTapped(AppCore.Character.ID)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case characterCreated(AppCore.Character)
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
                state.createForm = CreateCharacterFormState()
                return .none

            case let .updateCreateFormName(name):
                state.createForm.name = name
                return .none

            case let .updateCreateFormPersonality(personality):
                state.createForm.personality = personality
                return .none

            case let .updateCreateFormSpeechStyle(speechStyle):
                state.createForm.speechStyle = speechStyle
                return .none

            case let .updateCreateFormBackground(background):
                state.createForm.background = background
                return .none

            case .submitCreate:
                let now = Date()
                let character = AppCore.Character(
                    name: state.createForm.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    personality: state.createForm.personality.nilIfBlank,
                    speechStyle: state.createForm.speechStyle.nilIfBlank,
                    background: state.createForm.background.nilIfBlank,
                    createdAt: now,
                    updatedAt: now
                )
                state.isShowingCreateModal = false
                state.createForm = CreateCharacterFormState()
                return .send(.delegate(.characterCreated(character)))

            case let .characterTapped(id):
                guard let character = state.characters.first(where: { $0.id == id }) else {
                    return .none
                }
                state.detail = CharacterDetailFeature.State(character: character)
                return .none

            case .detail(.backTapped):
                state.detail = nil
                return .none

            case .detail:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.detail, action: \.detail) {
            CharacterDetailFeature()
        }
    }
}
