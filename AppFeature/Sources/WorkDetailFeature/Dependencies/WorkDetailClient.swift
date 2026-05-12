import AppCore
import ComposableArchitecture
import Foundation
import Persistance

public struct WorkDetailClient: Sendable {
    public var update: @Sendable (Work) async throws -> Void

    public init(update: @escaping @Sendable (Work) async throws -> Void) {
        self.update = update
    }
}

extension WorkDetailClient: DependencyKey {
    public static let liveValue: WorkDetailClient = .init(
        update: { work in
            try await updateWorkOnMainActor(work)
        }
    )

    public static let testValue: WorkDetailClient = .init(
        update: { _ in }
    )

    @MainActor
    private static func updateWorkOnMainActor(_ work: Work) throws {
        let client = try WorkClient.sharedLive()
        try client.update(work)
    }
}

public extension DependencyValues {
    var workDetailClient: WorkDetailClient {
        get { self[WorkDetailClient.self] }
        set { self[WorkDetailClient.self] = newValue }
    }
}
