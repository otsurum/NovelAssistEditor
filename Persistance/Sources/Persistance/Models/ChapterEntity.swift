import Foundation
import SwiftData

@Model
public final class ChapterEntity {
    @Attribute(.unique) public var id: UUID
    public var episodeTitle: String
    public var body: String

    public init(
        id: UUID,
        episodeTitle: String,
        body: String
    ) {
        self.id = id
        self.episodeTitle = episodeTitle
        self.body = body
    }
}
