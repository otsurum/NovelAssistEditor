import Foundation
import SwiftData

@Model
public final class CharacterEntity {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var personality: String?
    public var speechStyle: String?
    public var background: String?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID,
        name: String,
        personality: String?,
        speechStyle: String?,
        background: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.personality = personality
        self.speechStyle = speechStyle
        self.background = background
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
