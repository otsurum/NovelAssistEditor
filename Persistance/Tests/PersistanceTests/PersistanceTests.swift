import AppCore
import Foundation
@testable import Persistance
import Testing

@MainActor
@Test func characterClientCreatesFetchesAndUpdatesCharacters() throws {
    let container = try ModelContainerFactory.makeShared(inMemoryOnly: true)
    let client = CharacterClient(modelContext: container.mainContext)

    let createdAt = Date(timeIntervalSince1970: 1000)
    let updatedAt = Date(timeIntervalSince1970: 2000)
    let character = try AppCore.Character(
        id: #require(UUID(uuidString: "00000000-0000-0000-0000-000000000001")),
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
        updatedAt: Date(timeIntervalSince1970: 3000)
    )

    try client.update(editedCharacter)

    #expect(try client.fetchAll() == [editedCharacter])
}

@MainActor
@Test func workClientPersistsCharacters() throws {
    let container = try ModelContainerFactory.makeShared(inMemoryOnly: true)
    let characterClient = CharacterClient(modelContext: container.mainContext)
    let workClient = WorkClient(modelContext: container.mainContext)

    let characterCreatedAt = Date(timeIntervalSince1970: 1000)
    let character = try AppCore.Character(
        id: #require(UUID(uuidString: "00000000-0000-0000-0000-000000000011")),
        name: "浅倉 澪",
        personality: "明るいが秘密主義",
        speechStyle: "軽い冗談を挟む",
        background: "古書店の店主",
        createdAt: characterCreatedAt,
        updatedAt: Date(timeIntervalSince1970: 2000)
    )
    try characterClient.create(character)

    let workCreatedAt = Date(timeIntervalSince1970: 3000)
    let work = try Work(
        id: #require(UUID(uuidString: "00000000-0000-0000-0000-000000000101")),
        title: "夜明けの書架",
        characters: [character],
        createdAt: workCreatedAt,
        updatedAt: Date(timeIntervalSince1970: 4000)
    )

    try workClient.create(work)

    #expect(try workClient.fetchAll() == [work])

    let editedCharacter = AppCore.Character(
        id: character.id,
        name: "浅倉 澪",
        personality: "明るいが秘密主義で、土壇場に強い",
        speechStyle: "軽い冗談を挟みつつ、要点は短い",
        background: "古書店の店主。禁書の来歴を隠している",
        createdAt: characterCreatedAt,
        updatedAt: Date(timeIntervalSince1970: 5000)
    )
    let addedCharacter = try AppCore.Character(
        id: #require(UUID(uuidString: "00000000-0000-0000-0000-000000000012")),
        name: "久瀬 蓮",
        personality: "冷静で義理堅い",
        speechStyle: "無駄のない断定口調",
        background: "元警備員",
        createdAt: Date(timeIntervalSince1970: 6000),
        updatedAt: Date(timeIntervalSince1970: 7000)
    )
    let editedWork = Work(
        id: work.id,
        title: "夜明けの書架 改稿版",
        characters: [editedCharacter, addedCharacter],
        createdAt: workCreatedAt,
        updatedAt: Date(timeIntervalSince1970: 8000)
    )

    try workClient.update(editedWork)

    #expect(try workClient.fetchAll() == [editedWork])
}
