import AppCore
import CharacterDetailFeature
import SwiftUI

#if os(macOS)
    import AppKit
#endif

public struct CharacterCardListView: View {
    let characters: [AppCore.Character]

    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 24, alignment: .top),
    ]

    public init(characters: [AppCore.Character]) {
        self.characters = characters
    }

    public var body: some View {
        content
            .navigationTitle("キャラクター")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.characterCardListBackground)
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if characters.isEmpty {
                ContentUnavailableView(
                    "キャラクターがいません",
                    systemImage: "person.crop.circle",
                    description: Text("まずはキャラクターを1人追加してください。")
                )
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
                                NavigationLink {
                                    CharacterDetailView(character: character)
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
                            .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text(character.name)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

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
            .frame(width: 180, height: 134)

            Text(character.updatedAt.formatted(date: .numeric, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
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
            Color(nsColor: .controlBackgroundColor)
        #else
            Color(.secondarySystemBackground)
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
