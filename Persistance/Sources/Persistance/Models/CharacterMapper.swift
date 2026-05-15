import AppCore
import Foundation

enum CharacterMapper {
    static func toDomain(_ entity: CharacterEntity) -> AppCore.Character {
        AppCore.Character(
            id: entity.id,
            name: entity.name,
            personality: entity.personality,
            speechStyle: entity.speechStyle,
            background: entity.background,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt
        )
    }

    static func toEntity(_ character: AppCore.Character) -> CharacterEntity {
        CharacterEntity(
            id: character.id,
            name: character.name,
            personality: character.personality,
            speechStyle: character.speechStyle,
            background: character.background,
            createdAt: character.createdAt,
            updatedAt: character.updatedAt
        )
    }

    static func apply(_ character: AppCore.Character, to entity: CharacterEntity) {
        entity.name = character.name
        entity.personality = character.personality
        entity.speechStyle = character.speechStyle
        entity.background = character.background
        entity.updatedAt = character.updatedAt
    }
}
