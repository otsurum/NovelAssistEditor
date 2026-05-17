import Foundation

public struct Story: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var chapters: [Chapter]

    public init(
        id: UUID = UUID(),
        chapters: [Chapter] = []
    ) {
        self.id = id
        self.chapters = chapters
    }
}
