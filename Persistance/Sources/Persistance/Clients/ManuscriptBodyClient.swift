import AppCore
import Foundation
import SwiftData

public final class ManuscriptBodyClient: ManuscriptBodyRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetchAll() throws -> [ManuscriptBody] {
        let descriptor = FetchDescriptor<ManuscriptBodyEntity>()
        let entities = try modelContext.fetch(descriptor)
        return try entities.map(ManuscriptBodyMapper.toDomain)
    }

    public func fetch(id: UUID) throws -> ManuscriptBody {
        try ManuscriptBodyMapper.toDomain(fetchEntity(id: id))
    }

    public func create(_ body: ManuscriptBody) throws {
        let entity = ManuscriptBodyMapper.toEntity(body)
        modelContext.insert(entity)
        try modelContext.save()
    }

    public func update(_ body: ManuscriptBody) throws {
        let entity = try fetchEntity(id: body.id)
        ManuscriptBodyMapper.apply(body, to: entity)
        try modelContext.save()
    }

    public func delete(id: UUID) throws {
        let entity = try fetchEntity(id: id)
        modelContext.delete(entity)
        try modelContext.save()
    }

    private func fetchEntity(id: UUID) throws -> ManuscriptBodyEntity {
        let bodyID = id
        let descriptor = FetchDescriptor<ManuscriptBodyEntity>(
            predicate: #Predicate<ManuscriptBodyEntity> { entity in
                entity.id == bodyID
            }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            throw ManuscriptBodyClientError.bodyNotFound
        }

        return entity
    }
}

extension ManuscriptBodyClient {
    @MainActor private static var sharedContainer: ModelContainer?

    @MainActor
    public static func sharedLive() throws -> ManuscriptBodyClient {
        if let container = sharedContainer {
            return ManuscriptBodyClient(modelContext: container.mainContext)
        }

        let container = try ModelContainerFactory.makeShared()
        sharedContainer = container
        return ManuscriptBodyClient(modelContext: container.mainContext)
    }
}

public enum ManuscriptBodyClientError: LocalizedError {
    case bodyNotFound
    case databaseAccessFailed(String)
    case invalidData(String)

    public var errorDescription: String? {
        switch self {
        case .bodyNotFound:
            "対象の本文が見つかりません。"
        case .databaseAccessFailed:
            "データベースへのアクセスに失敗しました。"
        case .invalidData:
            "データの読み込みに失敗しました。"
        }
    }

    public var debugDescription: String {
        switch self {
        case .bodyNotFound:
            "ManuscriptBodyClientError.bodyNotFound"
        case let .databaseAccessFailed(reason):
            "ManuscriptBodyClientError.databaseAccessFailed: \(reason)"
        case let .invalidData(reason):
            "ManuscriptBodyClientError.invalidData: \(reason)"
        }
    }
}
