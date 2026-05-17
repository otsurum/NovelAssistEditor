import Foundation

public protocol CharacterRepository {
    func fetchAll() throws -> [Character]
    func create(_ character: Character) throws
    func update(_ character: Character) throws
    func delete(id: UUID) throws
}
