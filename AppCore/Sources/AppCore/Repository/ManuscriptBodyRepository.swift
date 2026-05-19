import Foundation

public protocol ManuscriptBodyRepository {
    func fetchAll() throws -> [ManuscriptBody]
    func fetch(id: UUID) throws -> ManuscriptBody
    func create(_ body: ManuscriptBody) throws
    func update(_ body: ManuscriptBody) throws
    func delete(id: UUID) throws
}
