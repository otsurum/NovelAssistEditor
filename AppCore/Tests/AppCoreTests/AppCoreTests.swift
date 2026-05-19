@testable import AppCore
import Testing

@Test func manuscriptLineRejectsTextOverFortyCharacters() {
    let text = String(repeating: "あ", count: ManuscriptLine.maxCharacterCount + 1)

    do {
        _ = try ManuscriptLine(text: text)
        #expect(Bool(false))
    } catch let error as ManuscriptBodyError {
        #expect(
            error == .lineTextTooLong(
                maximum: ManuscriptLine.maxCharacterCount,
                actual: text.count
            )
        )
    } catch {
        #expect(Bool(false))
    }
}

@Test func manuscriptPageRejectsMoreThanSeventeenLines() throws {
    let lines = try (0 ..< ManuscriptPage.maxLineCount + 1).map { index in
        try ManuscriptLine(text: "\(index)")
    }

    do {
        _ = try ManuscriptPage(lines: lines)
        #expect(Bool(false))
    } catch let error as ManuscriptBodyError {
        #expect(
            error == .pageLineCountTooLarge(
                maximum: ManuscriptPage.maxLineCount,
                actual: lines.count
            )
        )
    } catch {
        #expect(Bool(false))
    }
}

@Test func manuscriptBodyWrapsTextIntoFortyCharacterLines() {
    let text = String(repeating: "あ", count: ManuscriptLine.maxCharacterCount + 1)
    let body = ManuscriptBody(text: text)

    #expect(body.pageCount == 1)
    #expect(body.lineCount == 2)
    #expect(body.pages[0].lines[0].text.count == ManuscriptLine.maxCharacterCount)
    #expect(body.pages[0].lines[1].text.count == 1)
}

@Test func manuscriptBodyPaginatesEverySeventeenLines() {
    let text = String(
        repeating: "あ",
        count: ManuscriptLine.maxCharacterCount * ManuscriptPage.maxLineCount + 1
    )
    let body = ManuscriptBody(text: text)

    #expect(body.pageCount == 2)
    #expect(body.pages[0].lines.count == ManuscriptPage.maxLineCount)
    #expect(body.pages[1].lines.count == 1)
    #expect(body.pages[1].lines[0].text.count == 1)
}

@Test func manuscriptBodyPreservesExplicitBlankLines() {
    let body = ManuscriptBody(text: "一行目\n\n三行目")

    #expect(body.lineCount == 3)
    #expect(body.lines.map(\.text) == ["一行目", "", "三行目"])
}
