import Foundation

public struct FetchWorksUseCase: Sendable {
    private let repository: any WorkRepository

    public init(repository: any WorkRepository) {
        self.repository = repository
    }

    public func execute() throws -> [Work] {
        try repository.fetchAll()
    }
}
