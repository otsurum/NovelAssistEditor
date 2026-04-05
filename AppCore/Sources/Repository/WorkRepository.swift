import Foundation

public protocol WorkRepository: Sendable {
    func fetchAll() throws -> [Work]
    func create(_ work: Work) throws
    func update(_ work: Work) throws
    func delete(id: UUID) throws
}
