import AppCore
import Foundation

enum StoryMapper {
    static func toDomain(_ entity: StoryEntity?) -> Story {
        guard let entity else {
            return Story()
        }

        return Story(
            id: entity.id,
            chapters: entity.chapters.map(ChapterMapper.toDomain)
        )
    }

    static func toEntity(_ story: Story) -> StoryEntity {
        StoryEntity(
            id: story.id,
            chapters: story.chapters.map(ChapterMapper.toEntity)
        )
    }

    static func apply(_ story: Story, to entity: StoryEntity) {
        var existingChaptersByID = Dictionary(
            uniqueKeysWithValues: entity.chapters.map { ($0.id, $0) }
        )

        entity.chapters = story.chapters.map { chapter in
            if let existingChapter = existingChaptersByID.removeValue(forKey: chapter.id) {
                ChapterMapper.apply(chapter, to: existingChapter)
                return existingChapter
            }

            return ChapterMapper.toEntity(chapter)
        }
    }
}

enum ChapterMapper {
    static func toDomain(_ entity: ChapterEntity) -> Chapter {
        Chapter(
            id: entity.id,
            episodeTitle: entity.episodeTitle,
            body: entity.body
        )
    }

    static func toEntity(_ chapter: Chapter) -> ChapterEntity {
        ChapterEntity(
            id: chapter.id,
            episodeTitle: chapter.episodeTitle,
            body: chapter.body
        )
    }

    static func apply(_ chapter: Chapter, to entity: ChapterEntity) {
        entity.episodeTitle = chapter.episodeTitle
        entity.body = chapter.body
    }
}
