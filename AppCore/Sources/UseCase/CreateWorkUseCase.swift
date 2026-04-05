import Foundation

public struct CreateWorkUseCase: Sendable {
    private let repository: any WorkRepository

    public init(repository: any WorkRepository) {
        self.repository = repository
    }

    public func execute(
        title: String,
        summary: String? = nil,
        styleMemo: String? = nil,
        theme: String? = nil
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw WorkValidationError.emptyTitle
        }

        let work = Work(
            title: trimmedTitle,
            summary: summary?.nilIfBlank,
            styleMemo: styleMemo?.nilIfBlank,
            theme: theme?.nilIfBlank
        )

        try repository.create(work)
    }
}

public enum WorkValidationError: LocalizedError {
    case emptyTitle

    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "タイトルは必須です。"
        }
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
