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

private struct CreateCharacterFormState: Equatable {
    var name = ""
    var personality = ""
    var speechStyle = ""
    var background = ""

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct CreateCharacterModal: View {
    @Binding var form: CreateCharacterFormState
    let onCancel: () -> Void
    let onCreate: (AppCore.Character) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("名前", text: $form.name)
                        .textFieldStyle(.roundedBorder)
                }

                Section(header: Text("設定資料")) {
                    TextField("性格", text: $form.personality, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3 ... 5)

                    TextField("口調", text: $form.speechStyle, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3 ... 5)

                    TextField("背景", text: $form.background, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4 ... 8)
                }
            }
            .navigationTitle("新規キャラクター")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        onCreate(makeCharacter())
                    }
                    .disabled(!form.isValid)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        onCancel()
                    }
                }
            }
        }
    }

    private func makeCharacter() -> AppCore.Character {
        let now = Date()

        return AppCore.Character(
            name: form.name.trimmingCharacters(in: .whitespacesAndNewlines),
            personality: form.personality.nilIfBlank,
            speechStyle: form.speechStyle.nilIfBlank,
            background: form.background.nilIfBlank,
            createdAt: now,
            updatedAt: now
        )
    }
}

private struct CharacterCard: View {
    let character: AppCore.Character

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.characterCardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.characterCardBorder, lineWidth: 1)
                    }

                HStack(alignment: .top, spacing: 0) {
                    Rectangle()
                        .fill(Color.characterCardAccent)
                        .frame(width: 5)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "person.crop.circle")
                                .font(.title3)
                                .foregroundStyle(Color.characterCardAccent)

                            Text(character.name)
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }

                        if let previewText {
                            Text(previewText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(4)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.characterCardBackground)
                    .shadow(color: Color.characterCardAccent.opacity(0.08), radius: 8, x: 0, y: 3)
            }
            .frame(width: 180, height: 134)

            HStack(spacing: 5) {
                Image(systemName: "person.text.rectangle")
                    .font(.caption2)

                Text(character.updatedAt.formatted(date: .numeric, time: .omitted))
                    .lineLimit(1)
            }
            .font(.caption)
            .foregroundStyle(Color.characterCardAccent)
            .frame(width: 180)
        }
        .frame(width: 180, alignment: .top)
        .contentShape(Rectangle())
    }

    private var previewText: String? {
        for text in [character.personality, character.speechStyle, character.background] {
            if let text, !text.isEmpty {
                return text
            }
        }
        return nil
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
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

    static var characterCardBackground: Color {
        #if os(macOS)
            Color(nsColor: .controlAccentColor).opacity(0.10)
        #else
            Color(.systemTeal).opacity(0.10)
        #endif
    }

    static var characterCardBorder: Color {
        #if os(macOS)
            Color(nsColor: .controlAccentColor).opacity(0.34)
        #else
            Color(.systemTeal).opacity(0.34)
        #endif
    }

    static var characterCardAccent: Color {
        #if os(macOS)
            Color(nsColor: .controlAccentColor)
        #else
            Color(.systemTeal)
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
