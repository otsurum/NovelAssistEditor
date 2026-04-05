import SwiftData

public enum ModelContainerFactory {
    public static func makeShared(inMemoryOnly: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: AppSchema.schema,
            isStoredInMemoryOnly: inMemoryOnly
        )

        return try ModelContainer(
            for: AppSchema.schema,
            configurations: [configuration]
        )
    }
}
