import AppCore
import ComposableArchitecture
import Foundation
import Persistance
import SwiftData

/// Persistance から WorkClientError と WorkClient をインポート
typealias WorkClientError = Persistance.WorkClientError

@DependencyClient
public struct WorkListClient: Sendable {
    public var fetchWorks: @Sendable () async throws -> [Work]
    public var create: @Sendable (Work) async throws -> Void
}

extension WorkListClient: DependencyKey {
    public static let liveValue = Self(
        fetchWorks: {
            do {
                return try await fetchWorksOnMainActor()
            } catch let error as WorkClientError {
                // WorkClient 固有エラー
                print("❌ WorkClient error: \(error.localizedDescription)")
                throw error
            } catch {
                // その他のエラー（DBアクセス失敗など）
                print("❌ Unexpected error during fetch: \(error.localizedDescription)")
                throw WorkClientError.databaseAccessFailed(error.localizedDescription)
            }
        },
        create: { work in
            do {
                try await createWorkOnMainActor(work)
            } catch let error as WorkClientError {
                // WorkClient 固有エラー
                print("❌ WorkClient error: \(error.localizedDescription)")
                throw error
            } catch {
                // その他のエラー（DBアクセス失敗など）
                print("❌ Unexpected error during create: \(error.localizedDescription)")
                throw WorkClientError.databaseAccessFailed(error.localizedDescription)
            }
        }
    )

    public static let testValue = Self(
        fetchWorks: {
            []
        },
        create: { _ in
            // Test implementation
        }
    )

    @MainActor
    private static func fetchWorksOnMainActor() async throws -> [Work] {
        let container = try ModelContainerFactory.makeShared()
        let workClient = WorkClient(modelContext: container.mainContext)
        return try workClient.fetchAll()
    }

    @MainActor
    private static func createWorkOnMainActor(_ work: Work) async throws {
        let container = try ModelContainerFactory.makeShared()
        let workClient = WorkClient(modelContext: container.mainContext)
        try workClient.create(work)
    }
}

public extension DependencyValues {
    var workListClient: WorkListClient {
        get { self[WorkListClient.self] }
        set { self[WorkListClient.self] = newValue }
    }
}
