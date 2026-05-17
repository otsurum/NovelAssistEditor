import Foundation

public struct Character: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var personality: String?
    public var speechStyle: String?
    public var background: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        personality: String? = nil,
        speechStyle: String? = nil,
        background: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
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
