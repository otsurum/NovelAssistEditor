import Foundation

public struct Work: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var summary: String?
    public var styleMemo: String?
    public var theme: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        summary: String? = nil,
        styleMemo: String? = nil,
        theme: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.styleMemo = styleMemo
        self.theme = theme
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
