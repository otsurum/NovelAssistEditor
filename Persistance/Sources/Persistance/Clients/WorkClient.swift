import AppCore
import Foundation
import SwiftData

public final class WorkClient: WorkRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetchAll() throws -> [Work] {
        let descriptor = FetchDescriptor<WorkEntity>(
            sortBy: [
                SortDescriptor(\WorkEntity.updatedAt, order: .reverse),
            ]
        )

        let entities = try modelContext.fetch(descriptor)
        return entities.map(WorkMapper.toDomain)
    }

    public func create(_ work: Work) throws {
        let characters = try characterEntities(for: work.characters)
        let story = StoryMapper.toEntity(work.story)
        let entity = WorkMapper.toEntity(work, characters: characters, story: story)
        modelContext.insert(entity)
        try modelContext.save()
    }

    public func update(_ work: Work) throws {
        let workID = work.id
        let descriptor = FetchDescriptor<WorkEntity>(
            predicate: #Predicate<WorkEntity> { entity in
                entity.id == workID
            }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            throw WorkClientError.workNotFound
        }

        let characters = try characterEntities(for: work.characters)
        let story = entity.story ?? StoryMapper.toEntity(work.story)
        WorkMapper.apply(work, characters: characters, story: story, to: entity)
        try modelContext.save()
    }

    public func delete(id: UUID) throws {
        let descriptor = FetchDescriptor<WorkEntity>(
            predicate: #Predicate<WorkEntity> { entity in
                entity.id == id
            }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            throw WorkClientError.workNotFound
        }

        modelContext.delete(entity)
        try modelContext.save()
    }

    private func characterEntities(for characters: [AppCore.Character]) throws -> [CharacterEntity] {
        try characters.map { character in
            if let entity = try fetchCharacterEntity(id: character.id) {
                CharacterMapper.apply(character, to: entity)
                return entity
            }

            let entity = CharacterMapper.toEntity(character)
            modelContext.insert(entity)
            return entity
        }
    }

    private func fetchCharacterEntity(id: UUID) throws -> CharacterEntity? {
        let characterID = id
        let descriptor = FetchDescriptor<CharacterEntity>(
            predicate: #Predicate<CharacterEntity> { entity in
                entity.id == characterID
            }
        )

        return try modelContext.fetch(descriptor).first
    }
}

extension WorkClient {
    @MainActor private static var sharedContainer: ModelContainer?

    /// AppFeature など SwiftData に直接依存させたくない層から使う共有ファクトリ
    @MainActor
    public static func sharedLive() throws -> WorkClient {
        if let container = sharedContainer {
            return WorkClient(modelContext: container.mainContext)
        }
        let container = try ModelContainerFactory.makeShared()
        sharedContainer = container
        return WorkClient(modelContext: container.mainContext)
    }
}

public enum WorkClientError: LocalizedError {
    case workNotFound
    case databaseAccessFailed(String)
    case invalidData(String)

    public var errorDescription: String? {
        switch self {
        case .workNotFound:
            "対象の作品が見つかりません。"
        case .databaseAccessFailed:
            "データベースへのアクセスに失敗しました。"
        case .invalidData:
            "データの読み込みに失敗しました。"
        }
    }

    public var debugDescription: String {
        switch self {
        case .workNotFound:
            "WorkClientError.workNotFound"
        case let .databaseAccessFailed(reason):
            "WorkClientError.databaseAccessFailed: \(reason)"
        case let .invalidData(reason):
            "WorkClientError.invalidData: \(reason)"
        }
    }
}
