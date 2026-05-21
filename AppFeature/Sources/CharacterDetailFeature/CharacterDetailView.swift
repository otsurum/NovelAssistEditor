import AppCore
import ComposableArchitecture
import Extension
import SwiftUI

public struct CharacterDetailView: View {
    let store: StoreOf<CharacterDetailFeature>

    public init(store: StoreOf<CharacterDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Button {
                    store.send(.backTapped)
                } label: {
                    Label("キャラクター", systemImage: "chevron.left")
                }
                .buttonStyle(.borderless)

                VStack(alignment: .leading, spacing: 6) {
                    Text(store.character.name)
                        .font(.largeTitle.weight(.bold))
                        .lineLimit(nil)

                    Text("更新日 \(store.character.updatedAt.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 4)

                if isBodyEmpty {
                    Text("このキャラクターにはまだメモがありません。")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if let personality = store.character.personality, !personality.isEmpty {
                    DetailSection(title: "性格", systemImage: "person.fill", bodyText: personality)
                }

                if let speechStyle = store.character.speechStyle, !speechStyle.isEmpty {
                    DetailSection(title: "口調", systemImage: "bubble.left.fill", bodyText: speechStyle)
                }

                if let background = store.character.background, !background.isEmpty {
                    DetailSection(title: "背景", systemImage: "clock.fill", bodyText: background)
                }

                Spacer()
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.vertical, 32)
        }
        .navigationTitle(store.character.name)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.characterDetailBackground)
    }

    private var isBodyEmpty: Bool {
        [store.character.personality, store.character.speechStyle, store.character.background]
            .compactMap(\.self)
            .allSatisfy(\.isEmpty)
    }
}

private struct DetailSection: View {
    let title: String
    let systemImage: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(bodyText)
                .font(.body)
                .lineSpacing(4)
                .lineLimit(nil)
        }
    }
}

#Preview {
    let sampleCharacter = AppCore.Character(
        name: "田中 太郎",
        personality: "明るく前向きな性格で、困難な状況でも笑顔を忘れない。",
        speechStyle: "敬語を使わず、フランクに話す。語尾に「だよ」が多い。",
        background: "小さな漁村で育ち、18歳で都市に出てきた。両親は漁師。"
    )

    let store = Store(
        initialState: CharacterDetailFeature.State(character: sampleCharacter),
        reducer: { CharacterDetailFeature() }
    )

    CharacterDetailView(store: store)
}
