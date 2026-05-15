import AppCore
import CharacterDetailFeature
import SwiftUI

#if os(macOS)
    import AppKit
#endif

public struct CharacterCardListView: View {
    let characters: [AppCore.Character]
    let onCreate: (AppCore.Character) -> Void
    @State private var isShowingCreateCharacterModal = false
    @State private var createForm = CreateCharacterFormState()
    @State private var selectedCharacterID: AppCore.Character.ID?

    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 24, alignment: .top),
    ]

    public init(
        characters: [AppCore.Character],
        onCreate: @escaping (AppCore.Character) -> Void = { _ in }
    ) {
        self.characters = characters
        self.onCreate = onCreate
    }

    public var body: some View {
        content
            .navigationTitle(navigationTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.characterCardListBackground)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingCreateCharacterModal = true
                    } label: {
                        Label("キャラクターを追加", systemImage: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateCharacterModal) {
                CreateCharacterModal(
                    form: $createForm,
                    onCancel: dismissCreateModal,
                    onCreate: { character in
                        onCreate(character)
                        dismissCreateModal()
                    }
                )
                .presentationDetents([.medium, .large])
            }
    }

    private var content: some View {
        Group {
            if let selectedCharacter {
                CharacterDetailView(character: selectedCharacter) {
                    selectedCharacterID = nil
                }
            } else if characters.isEmpty {
                VStack(spacing: 14) {
                    ContentUnavailableView(
                        "キャラクターがいません",
                        systemImage: "person.crop.circle",
                        description: Text("まずはキャラクターを1人追加してください。")
                    )

                    Button {
                        isShowingCreateCharacterModal = true
                    } label: {
                        Label("キャラクターを追加", systemImage: "person.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("すべてのキャラクター")
                                .font(.title2.weight(.semibold))
                                .lineLimit(1)

                            Text("\(characters.count)人のキャラクター")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        LazyVGrid(columns: columns, alignment: .leading, spacing: 30) {
                            ForEach(characters) { character in
                                Button {
                                    selectedCharacterID = character.id
                                } label: {
                                    CharacterCard(character: character)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 26)
                }
            }
        }
    }

    private func dismissCreateModal() {
        createForm = CreateCharacterFormState()
        isShowingCreateCharacterModal = false
    }

    private var selectedCharacter: AppCore.Character? {
        guard let selectedCharacterID else { return nil }
        return characters.first { $0.id == selectedCharacterID }
    }

    private var navigationTitle: String {
        selectedCharacter?.name ?? "キャラクター"
    }
}

private extension Color {
    static var characterCardListBackground: Color {
        #if os(macOS)
            Color(nsColor: .textBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
    }
}

#Preview {
    let characters = [
        AppCore.Character(
            name: "田中 太郎",
            personality: "明るく前向きな性格で、困難な状況でも笑顔を忘れない。",
            speechStyle: "フランクに話す。語尾に「だよ」が多い。",
            background: "小さな漁村で育ち、18歳で都市に出てきた。"
        ),
        AppCore.Character(
            name: "佐藤 花子",
            personality: "冷静沈着で論理的。感情を表に出すのが苦手。",
            speechStyle: "丁寧語を使う。短く簡潔に話す。",
            background: "都市部の裕福な家庭で育った。"
        ),
        AppCore.Character(
            name: "鈴木 次郎",
            background: "元軍人。今は農業を営んでいる。"
        ),
    ]

    NavigationStack {
        CharacterCardListView(characters: characters)
    }
}
