import AppCore
import ComposableArchitecture
import Foundation

@DependencyClient
public struct WorkListClient: Sendable {
    public var fetchWorks: @Sendable () async throws -> [Work]
}

extension WorkListClient: DependencyKey {
    public static let liveValue = Self(
        fetchWorks: {
            []
        }
    )

    public static let testValue = Self(
        fetchWorks: {
            []
        }
    )
}

public extension DependencyValues {
    var workListClient: WorkListClient {
        get { self[WorkListClient.self] }
        set { self[WorkListClient.self] = newValue }
    }
}
