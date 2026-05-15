import AppCore
@testable import Persistance
import Foundation
import Testing

@MainActor
@Test func characterClientCreatesFetchesAndUpdatesCharacters() throws {
    let container = try ModelContainerFactory.makeShared(inMemoryOnly: true)
    let client = CharacterClient(modelContext: container.mainContext)

    let createdAt = Date(timeIntervalSince1970: 1_000)
    let updatedAt = Date(timeIntervalSince1970: 2_000)
    let character = AppCore.Character(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "遠野 凛",
        personality: "慎重で観察力が高い",
        speechStyle: "丁寧だが核心では短く言い切る",
        background: "港町で育った元記者",
        createdAt: createdAt,
        updatedAt: updatedAt
    )

    try client.create(character)

    #expect(try client.fetchAll() == [character])

    let editedCharacter = AppCore.Character(
        id: character.id,
        name: "遠野 凛",
        personality: "慎重で、必要な場面では大胆",
        speechStyle: "穏やかな敬語",
        background: "港町で育った元記者。失踪事件を追っている",
        createdAt: createdAt,
        updatedAt: Date(timeIntervalSince1970: 3_000)
    )

    try client.update(editedCharacter)

    #expect(try client.fetchAll() == [editedCharacter])
}
