import AppCore
import CharacterDetailFeature
import Extension
import ComposableArchitecture
import SwiftUI

public struct CharacterCardListView: View {
    @Bindable var store: StoreOf<CharacterCardListFeature>
    let navigationTitleOverride: String?

    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 24, alignment: .top),
    ]

    public init(
        store: StoreOf<CharacterCardListFeature>,
        navigationTitleOverride: String? = nil
    ) {
        self.store = store
        self.navigationTitleOverride = navigationTitleOverride
    }

    public var body: some View {
        content
            .navigationTitle(navigationTitleOverride ?? navigationTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.characterCardListBackground)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.send(.showCreateModal)
                    } label: {
                        Label("キャラクターを追加", systemImage: "person.badge.plus")
                    }
                }
            }
            .sheet(
                isPresented: Binding(
                    get: { store.isShowingCreateModal },
                    set: { isPresented in
                        if !isPresented { store.send(.hideCreateModal) }
                    }
                )
            ) {
                CreateCharacterModal(store: store)
                    .presentationDetents([.medium, .large])
            }
    }

    private var content: some View {
        Group {
            if let detailStore = store.scope(state: \.detail, action: \.detail) {
                CharacterDetailView(store: detailStore)
            } else if store.characters.isEmpty {
                VStack(spacing: 14) {
                    ContentUnavailableView(
                        "キャラクターがいません",
                        systemImage: "person.crop.circle",
                        description: Text("まずはキャラクターを1人追加してください。")
                    )

                    Button {
                        store.send(.showCreateModal)
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

                            Text("\(store.characters.count)人のキャラクター")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        LazyVGrid(columns: columns, alignment: .leading, spacing: 30) {
                            ForEach(store.characters) { character in
                                Button {
                                    store.send(.characterTapped(character.id))
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

    private var navigationTitle: String {
        store.detail?.character.name ?? "キャラクター"
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

    let store = Store(
        initialState: CharacterCardListFeature.State(characters: characters),
        reducer: { CharacterCardListFeature() }
    )

    NavigationStack {
        CharacterCardListView(store: store)
    }
}
