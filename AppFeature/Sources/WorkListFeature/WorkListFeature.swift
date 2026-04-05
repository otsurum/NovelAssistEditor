import AppCore
import ComposableArchitecture
import Foundation

@Reducer
public struct WorkListFeature {
    @ObservableState
    public struct State: Equatable {
        public var works: [Work] = []
        public var isLoading = false
        @Presents public var alert: AlertState<Action.Alert>?

        public init() {}
    }

    public enum Action: Equatable {
        case task
        case retryButtonTapped
        case addButtonTapped
        case worksResponse(Result<[Work], FailureReason>)
        case alert(PresentationAction<Alert>)

        public enum Alert: Equatable {
            case dismiss
        }
    }

    public struct FailureReason: Error, Equatable, Sendable {
        public let message: String

        public init(_ message: String) {
            self.message = message
        }
    }

    @Dependency(\.workListClient) var workListClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task, .retryButtonTapped:
                state.isLoading = true
                state.alert = nil

                return .run { [workListClient] send in
                    do {
                        let works = try await workListClient.fetchWorks()
                        await send(.worksResponse(.success(works)))
                    } catch {
                        await send(
                            .worksResponse(
                                .failure(FailureReason(error.localizedDescription))
                            )
                        )
                    }
                }

            case let .worksResponse(.success(works)):
                state.isLoading = false
                state.works = works
                return .none

            case let .worksResponse(.failure(error)):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("読み込みに失敗しました")
                } actions: {
                    ButtonState(action: .dismiss) {
                        TextState("OK")
                    }
                } message: {
                    TextState(error.message)
                }
                return .none

            case .addButtonTapped:
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
