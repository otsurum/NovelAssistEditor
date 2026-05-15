import AppCore
import Foundation
import SwiftData

public final class CharacterClient: CharacterRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetchAll() throws -> [AppCore.Character] {
        let descriptor = FetchDescriptor<CharacterEntity>(
            sortBy: [
                SortDescriptor(\CharacterEntity.updatedAt, order: .reverse),
            ]
        )

        let entities = try modelContext.fetch(descriptor)
        return entities.map(CharacterMapper.toDomain)
    }

    public func create(_ character: AppCore.Character) throws {
        let entity = CharacterMapper.toEntity(character)
        modelContext.insert(entity)
        try modelContext.save()
    }

    public func update(_ character: AppCore.Character) throws {
        let characterID = character.id
        let descriptor = FetchDescriptor<CharacterEntity>(
            predicate: #Predicate<CharacterEntity> { entity in
                entity.id == characterID
            }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            throw CharacterClientError.characterNotFound
        }

        CharacterMapper.apply(character, to: entity)
        try modelContext.save()
    }

    public func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<CharacterEntity>(
            predicate: #Predicate<CharacterEntity> { entity in
                entity.id == id
            }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            throw CharacterClientError.characterNotFound
        }

        modelContext.delete(entity)
        try modelContext.save()
    }
}

extension CharacterClient {
    @MainActor private static var sharedContainer: ModelContainer?

    /// AppFeature など SwiftData に直接依存させたくない層から使う共有ファクトリ
    @MainActor
    public static func sharedLive() throws -> CharacterClient {
        if let container = sharedContainer {
            return CharacterClient(modelContext: container.mainContext)
        }
        let container = try ModelContainerFactory.makeShared()
        sharedContainer = container
        return CharacterClient(modelContext: container.mainContext)
    }
}

public enum CharacterClientError: LocalizedError {
    case characterNotFound
    case databaseAccessFailed(String)
    case invalidData(String)

    public var errorDescription: String? {
        switch self {
        case .characterNotFound:
            "対象のキャラクターが見つかりません。"
        case .databaseAccessFailed:
            "データベースへのアクセスに失敗しました。"
        case .invalidData:
            "データの読み込みに失敗しました。"
        }
    }

    public var debugDescription: String {
        switch self {
        case .characterNotFound:
            "CharacterClientError.characterNotFound"
        case let .databaseAccessFailed(reason):
            "CharacterClientError.databaseAccessFailed: \(reason)"
        case let .invalidData(reason):
            "CharacterClientError.invalidData: \(reason)"
        }
    }
}
