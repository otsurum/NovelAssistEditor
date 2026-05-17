import Foundation
import SwiftData

@Model
public final class StoryEntity {
    @Attribute(.unique) public var id: UUID
    @Relationship(deleteRule: .cascade) public var chapters: [ChapterEntity] = []

    public init(
        id: UUID,
        chapters: [ChapterEntity] = []
    ) {
        self.id = id
        self.chapters = chapters
    }
}
