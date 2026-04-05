import Foundation
import SwiftData

@Model
public final class WorkEntity {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var summary: String?
    public var styleMemo: String?
    public var theme: String?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID,
        title: String,
        summary: String?,
        styleMemo: String?,
        theme: String?,
        createdAt: Date,
        updatedAt: Date
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
