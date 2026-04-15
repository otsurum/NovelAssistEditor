import AppCore
import ComposableArchitecture
import Foundation

@Reducer
public struct WorkListFeature {
    @ObservableState
    public struct State: Equatable {
        public var works: [Work] = []
        public var isLoading = false

        public init() {}
    }

    public enum Action: Equatable {
        case task
        case retryButtonTapped
        case worksResponse(Result<[Work], FailureReason>)
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
                return .none
            }
        }
    }
}
