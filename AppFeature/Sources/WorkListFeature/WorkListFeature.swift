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

    public enum Action: Equatable {}

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
            }
        }
    }
}
