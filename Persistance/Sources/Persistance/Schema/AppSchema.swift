import SwiftData

extension Schema: @unchecked @retroactive Sendable {}

public enum AppSchema {
    public static let models: [any PersistentModel.Type] = [
        CharacterEntity.self,
        WorkEntity.self,
    ]

    public static var schema: Schema {
        Schema(models)
    }
}
