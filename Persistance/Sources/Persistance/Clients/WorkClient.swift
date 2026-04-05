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
        let entity = WorkMapper.toEntity(work)
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

        WorkMapper.apply(work, to: entity)
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
}

public enum WorkClientError: LocalizedError {
    case workNotFound

    public var errorDescription: String? {
        switch self {
        case .workNotFound:
            "対象の作品が見つかりません。"
        }
    }
}
