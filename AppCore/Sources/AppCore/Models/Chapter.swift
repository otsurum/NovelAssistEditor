import Foundation

public struct Chapter: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var episodeTitle: String
    public var body: String

    public var manuscriptBody: ManuscriptBody {
        ManuscriptBody(text: body)
    }

    public init(
        id: UUID = UUID(),
        episodeTitle: String,
        body: String = ""
    ) {
        self.id = id
        self.episodeTitle = episodeTitle
        self.body = body
    }
}
