import Foundation
import SwiftData

@Model
public final class ManuscriptBodyEntity {
    @Attribute(.unique) public var id: UUID
    @Relationship(deleteRule: .cascade) public var pages: [ManuscriptPageEntity] = []

    public init(
        id: UUID,
        pages: [ManuscriptPageEntity] = []
    ) {
        self.id = id
        self.pages = pages
    }
}

@Model
public final class ManuscriptPageEntity {
    @Attribute(.unique) public var id: UUID
    public var position: Int
    @Relationship(deleteRule: .cascade) public var lines: [ManuscriptLineEntity] = []

    public init(
        id: UUID,
        position: Int,
        lines: [ManuscriptLineEntity] = []
    ) {
        self.id = id
        self.position = position
        self.lines = lines
    }
}

@Model
public final class ManuscriptLineEntity {
    @Attribute(.unique) public var id: UUID
    public var position: Int
    public var text: String

    public init(
        id: UUID,
        position: Int,
        text: String
    ) {
        self.id = id
        self.position = position
        self.text = text
    }
}
