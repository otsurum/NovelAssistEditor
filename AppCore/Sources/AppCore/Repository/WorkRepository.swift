import Foundation

public protocol WorkRepository {
    func fetchAll() throws -> [Work]
    func create(_ work: Work) throws
    func update(_ work: Work) throws
    func delete(id: UUID) throws
}
