import AppCore
import ComposableArchitecture
import SwiftUI

public struct TextEditorView: View {
    @Bindable var store: StoreOf<TextEditorFeature>

    public init(store: StoreOf<TextEditorFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            manuscriptDisplay
            if store.isEditorVisible {
                Divider()
                editorPanel
            }
        }
        .navigationTitle(store.chapter.episodeTitle)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    store.send(.close)
                } label: {
                    Label("一覧に戻る", systemImage: "chevron.left")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.toggleEditorVisibility)
                } label: {
                    Label(
                        store.isEditorVisible ? "入力欄を隠す" : "入力欄を表示",
                        systemImage: store.isEditorVisible ? "rectangle.bottomthird.inset.filled" : "pencil"
                    )
                }
            }
        }
    }

    private var manuscriptDisplay: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: 24) {
                if store.manuscriptBody.pages.isEmpty {
                    ManuscriptPageGridView(lines: [], pageNumber: 1)
                } else {
                    ForEach(Array(store.manuscriptBody.pages.enumerated()), id: \.element.id) { index, page in
                        ManuscriptPageGridView(lines: page.lines, pageNumber: index + 1)
                    }
                }
            }
            .padding(24)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.manuscriptViewBackground)
    }

    private var editorPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("本文入力")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(store.rawText.count)文字 ・ \(store.manuscriptBody.lineCount)行 ・ \(store.manuscriptBody.pageCount)ページ")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            TextEditor(text: Binding(
                get: { store.rawText },
                set: { store.send(.textChanged($0)) }
            ))
            .font(.body)
            .frame(height: 160)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.manuscriptEditorBackground)
    }
}

#Preview {
    let chapter = Chapter(
        episodeTitle: "第一章：始まりの朝",
        body: "朝の光が窓から差し込み、部屋を柔らかく照らした。\n彼女はゆっくりと目を開け、新しい一日の始まりを感じた。\n遠くで鳥が鳴いている。\n彼女はベッドから起き上がり、窓の外を眺めた。"
    )

    let store = Store(
        initialState: TextEditorFeature.State(chapter: chapter),
        reducer: { TextEditorFeature() }
    )

    NavigationStack {
        TextEditorView(store: store)
    }
}
