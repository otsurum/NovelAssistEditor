import AppCore
import ComposableArchitecture
import Extension
import SwiftUI

#if os(macOS)
    import AppKit
#endif

public struct TextEditorView: View {
    @Bindable var store: StoreOf<TextEditorFeature>
    @State private var commitController = TextInputCommitController()

    public init(store: StoreOf<TextEditorFeature>) {
        self.store = store
    }

    public var body: some View {
        GeometryReader { proxy in
            let workspaceHeight = max(0, proxy.size.height - TextEditorStatusBarView.height)
            let workspaceSize = CGSize(width: proxy.size.width, height: workspaceHeight)
            let viewportWidth = TextEditorWritingAreaView.viewportWidth(for: workspaceSize)

            VStack(spacing: 0) {
                TextEditorWritingAreaView(
                    size: workspaceSize,
                    manuscriptBody: store.manuscriptBody,
                    text: Binding(
                        get: { store.rawText },
                        set: { store.send(.textChanged($0)) }
                    ),
                    isEditorVisible: store.isEditorVisible,
                    focusRequestID: store.focusRequestID,
                    commitController: commitController,
                    commitText: { store.send(.textEditingCommitted($0)) }
                )
                .frame(width: workspaceSize.width, height: workspaceSize.height)

                TextEditorStatusBarView(
                    cursorLine: cursorLine,
                    cursorColumn: cursorColumn,
                    characterCount: store.manuscriptBody.characterCount,
                    viewportWidth: viewportWidth
                )
            }
        }
        .navigationTitle(documentTitle)
        .background(Color.manuscriptViewBackground)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    commitController.commitEditing()
                    store.send(.close)
                } label: {
                    Label("戻る", systemImage: "chevron.left")
                }
                .help("戻る")
            }

            ToolbarItemGroup(placement: .primaryAction) {
                TextEditorToolbarButton(title: "入力", systemImage: "keyboard") {
                    store.send(.focusEditor)
                }

                TextEditorToolbarButton(title: "保存", systemImage: "square.and.arrow.down") {
                    commitController.commitEditing()
                    store.send(.save)
                }
                TextEditorToolbarButton(title: "取り消し", systemImage: "arrow.uturn.backward") {
                    sendTextAction(Selector(("undo:")))
                }
                TextEditorToolbarButton(title: "やり直し", systemImage: "arrow.uturn.forward") {
                    sendTextAction(Selector(("redo:")))
                }
                TextEditorToolbarButton(title: "コピー", systemImage: "doc.on.doc") {
                    sendTextAction(#selector(NSText.copy(_:)))
                }
                TextEditorToolbarButton(title: "検索", systemImage: "magnifyingglass") {
                    sendTextAction(#selector(NSResponder.performTextFinderAction(_:)))
                }
                TextEditorToolbarButton(title: "マーク", systemImage: "bookmark") {}
                TextEditorToolbarButton(title: "情報", systemImage: "info.circle") {}
                TextEditorToolbarButton(title: "フォーム", systemImage: "list.bullet.rectangle") {}
                TextEditorToolbarButton(
                    title: store.isEditorVisible ? "読取専用" : "編集",
                    systemImage: store.isEditorVisible ? "eye" : "pencil"
                ) {
                    commitController.commitEditing()
                    store.send(.toggleEditorVisibility)
                }
            }
        }
    }

    private func sendTextAction(_ selector: Selector) {
        #if os(macOS)
            NSApp.sendAction(selector, to: nil, from: nil)
        #endif
    }

    private var documentTitle: String {
        store.chapter.episodeTitle.isEmpty ? "名称未設定" : store.chapter.episodeTitle
    }

    private var cursorLine: Int {
        max(store.manuscriptBody.lineCount, 1)
    }

    private var cursorColumn: Int {
        guard let lastLine = store.manuscriptBody.lines.last else { return 1 }
        return min(lastLine.text.count + 1, ManuscriptLine.maxCharacterCount)
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
