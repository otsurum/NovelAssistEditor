import AppCore
import Foundation

enum WorkMapper {
    static func toDomain(_ entity: WorkEntity) -> Work {
        Work(
            id: entity.id,
            title: entity.title,
            summary: entity.summary,
            styleMemo: entity.styleMemo,
            theme: entity.theme,
            characters: entity.characters.map(CharacterMapper.toDomain),
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt
        )
    }

    static func toEntity(_ work: Work) -> WorkEntity {
        toEntity(work, characters: work.characters.map(CharacterMapper.toEntity))
    }

    static func toEntity(_ work: Work, characters: [CharacterEntity]) -> WorkEntity {
        WorkEntity(
            id: work.id,
            title: work.title,
            summary: work.summary,
            styleMemo: work.styleMemo,
            theme: work.theme,
            characters: characters,
            createdAt: work.createdAt,
            updatedAt: work.updatedAt
        )
    }

    static func apply(_ work: Work, to entity: WorkEntity) {
        apply(work, characters: work.characters.map(CharacterMapper.toEntity), to: entity)
    }

    static func apply(_ work: Work, characters: [CharacterEntity], to entity: WorkEntity) {
        entity.title = work.title
        entity.summary = work.summary
        entity.styleMemo = work.styleMemo
        entity.theme = work.theme
        entity.characters = characters
        entity.updatedAt = work.updatedAt
    }
}
