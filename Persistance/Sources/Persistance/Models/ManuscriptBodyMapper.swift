import AppCore
import Foundation

enum ManuscriptBodyMapper {
    static func toDomain(_ entity: ManuscriptBodyEntity) throws -> ManuscriptBody {
        ManuscriptBody(
            id: entity.id,
            pages: try entity.pages
                .sorted { $0.position < $1.position }
                .map(ManuscriptPageMapper.toDomain)
        )
    }

    static func toEntity(_ body: ManuscriptBody) -> ManuscriptBodyEntity {
        ManuscriptBodyEntity(
            id: body.id,
            pages: body.pages.enumerated().map { index, page in
                ManuscriptPageMapper.toEntity(page, position: index)
            }
        )
    }

    static func apply(_ body: ManuscriptBody, to entity: ManuscriptBodyEntity) {
        var existingPagesByID = Dictionary(
            uniqueKeysWithValues: entity.pages.map { ($0.id, $0) }
        )

        entity.pages = body.pages.enumerated().map { index, page in
            if let existingPage = existingPagesByID.removeValue(forKey: page.id) {
                ManuscriptPageMapper.apply(page, position: index, to: existingPage)
                return existingPage
            }

            return ManuscriptPageMapper.toEntity(page, position: index)
        }
    }
}

enum ManuscriptPageMapper {
    static func toDomain(_ entity: ManuscriptPageEntity) throws -> ManuscriptPage {
        try ManuscriptPage(
            id: entity.id,
            lines: entity.lines
                .sorted { $0.position < $1.position }
                .map(ManuscriptLineMapper.toDomain)
        )
    }

    static func toEntity(_ page: ManuscriptPage, position: Int) -> ManuscriptPageEntity {
        ManuscriptPageEntity(
            id: page.id,
            position: position,
            lines: page.lines.enumerated().map { index, line in
                ManuscriptLineMapper.toEntity(line, position: index)
            }
        )
    }

    static func apply(_ page: ManuscriptPage, position: Int, to entity: ManuscriptPageEntity) {
        entity.position = position

        var existingLinesByID = Dictionary(
            uniqueKeysWithValues: entity.lines.map { ($0.id, $0) }
        )

        entity.lines = page.lines.enumerated().map { index, line in
            if let existingLine = existingLinesByID.removeValue(forKey: line.id) {
                ManuscriptLineMapper.apply(line, position: index, to: existingLine)
                return existingLine
            }

            return ManuscriptLineMapper.toEntity(line, position: index)
        }
    }
}

enum ManuscriptLineMapper {
    static func toDomain(_ entity: ManuscriptLineEntity) throws -> ManuscriptLine {
        try ManuscriptLine(
            id: entity.id,
            text: entity.text
        )
    }

    static func toEntity(_ line: ManuscriptLine, position: Int) -> ManuscriptLineEntity {
        ManuscriptLineEntity(
            id: line.id,
            position: position,
            text: line.text
        )
    }

    static func apply(_ line: ManuscriptLine, position: Int, to entity: ManuscriptLineEntity) {
        entity.position = position
        entity.text = line.text
    }
}
