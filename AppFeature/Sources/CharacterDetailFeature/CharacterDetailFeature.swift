import AppCore
import ComposableArchitecture
import Foundation

@Reducer
public struct CharacterDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var character: AppCore.Character

        public init(character: AppCore.Character) {
            self.character = character
        }
    }

    public enum Action: Equatable {
        case backTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .backTapped:
                return .none
            }
        }
    }
}
