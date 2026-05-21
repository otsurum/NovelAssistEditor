import Foundation

public enum ManuscriptBodyError: Error, Equatable, Sendable {
    case lineTextTooLong(maximum: Int, actual: Int)
    case pageLineCountTooLarge(maximum: Int, actual: Int)
}

public struct ManuscriptLine: Identifiable, Equatable, Sendable {
    public static let maxCharacterCount = 40

    public let id: UUID
    public var text: String

    public init(
        id: UUID = UUID(),
        text: String = ""
    ) throws {
        guard text.count <= Self.maxCharacterCount else {
            throw ManuscriptBodyError.lineTextTooLong(
                maximum: Self.maxCharacterCount,
                actual: text.count
            )
        }

        self.id = id
        self.text = text
    }

    fileprivate init(uncheckedText text: String) {
        self.init(id: UUID(), uncheckedText: text)
    }

    fileprivate init(id: UUID, uncheckedText text: String) {
        self.id = id
        self.text = text
    }
}

public struct ManuscriptPage: Identifiable, Equatable, Sendable {
    public static let maxLineCount = 17

    public let id: UUID
    public var lines: [ManuscriptLine]

    public init(
        id: UUID = UUID(),
        lines: [ManuscriptLine] = []
    ) throws {
        guard lines.count <= Self.maxLineCount else {
            throw ManuscriptBodyError.pageLineCountTooLarge(
                maximum: Self.maxLineCount,
                actual: lines.count
            )
        }

        self.id = id
        self.lines = lines
    }

    public mutating func append(_ line: ManuscriptLine) throws {
        guard lines.count < Self.maxLineCount else {
            throw ManuscriptBodyError.pageLineCountTooLarge(
                maximum: Self.maxLineCount,
                actual: lines.count + 1
            )
        }

        lines.append(line)
    }

    fileprivate init(uncheckedLines lines: [ManuscriptLine]) {
        self.init(id: UUID(), uncheckedLines: lines)
    }

    fileprivate init(id: UUID, uncheckedLines lines: [ManuscriptLine]) {
        self.id = id
        self.lines = lines
    }
}

public struct ManuscriptBody: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var pages: [ManuscriptPage]

    public init(
        id: UUID = UUID(),
        pages: [ManuscriptPage] = []
    ) {
        self.id = id
        self.pages = pages
    }

    public init(
        id: UUID = UUID(),
        text: String
    ) {
        self.id = id
        pages = Self.paginate(text)
    }

    public func replacingText(_ text: String) -> ManuscriptBody {
        ManuscriptBody(
            id: id,
            pages: Self.paginate(text, reusingIDsFrom: pages)
        )
    }

    public var pageCount: Int {
        pages.count
    }

    public var lineCount: Int {
        pages.reduce(0) { $0 + $1.lines.count }
    }


    public var characterCount: Int {
        lines.reduce(0) { $0 + $1.text.count }
    }

    public var lines: [ManuscriptLine] {
        pages.flatMap(\.lines)
    }

    public mutating func append(_ page: ManuscriptPage) {
        pages.append(page)
    }

    private static func paginate(
        _ text: String,
        reusingIDsFrom existingPages: [ManuscriptPage] = []
    ) -> [ManuscriptPage] {
        let lineTexts = wrappedLineTexts(from: text)
        guard !lineTexts.isEmpty else { return [] }

        return lineTexts
            .chunked(maxLength: ManuscriptPage.maxLineCount)
            .enumerated()
            .map { pageIndex, lineTexts in
                let existingPage = existingPages[safe: pageIndex]
                let existingLines = existingPage?.lines ?? []
                let lines = lineTexts.enumerated().map { lineIndex, text in
                    ManuscriptLine(
                        id: existingLines[safe: lineIndex]?.id ?? UUID(),
                        uncheckedText: text
                    )
                }

                return ManuscriptPage(
                    id: existingPage?.id ?? UUID(),
                    uncheckedLines: lines
                )
            }
    }

    private static func wrappedLineTexts(from text: String) -> [String] {
        text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .flatMap { logicalLine in
                String(logicalLine)
                    .chunked(maxLength: ManuscriptLine.maxCharacterCount)
            }
    }
}

private extension String {
    func chunked(maxLength: Int) -> [String] {
        guard !isEmpty else { return [""] }

        var chunks: [String] = []
        var start = startIndex

        while start < endIndex {
            let end = index(
                start,
                offsetBy: maxLength,
                limitedBy: endIndex
            ) ?? endIndex
            chunks.append(String(self[start ..< end]))
            start = end
        }

        return chunks
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    func chunked(maxLength: Int) -> [[Element]] {
        guard !isEmpty else { return [] }

        return stride(from: 0, to: count, by: maxLength).map { startIndex in
            let endIndex = Swift.min(startIndex + maxLength, count)
            return Array(self[startIndex ..< endIndex])
        }
    }
}
