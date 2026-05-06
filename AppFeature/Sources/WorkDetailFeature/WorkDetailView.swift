import AppCore
import ComposableArchitecture
import SwiftUI

#if os(macOS)
import AppKit
#endif

public struct WorkDetailView: View {
    let store: StoreOf<WorkDetailFeature>

    public init(store: StoreOf<WorkDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if store.isEditing {
                EditWorkForm(store: store)
            } else {
                WorkDetailContent(store: store)
            }
        }
        .navigationTitle(store.work.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.workDetailBackground)
    }
}

private struct WorkDetailContent: View {
    let store: StoreOf<WorkDetailFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(store.work.title)
                        .font(.largeTitle.weight(.bold))
                        .lineLimit(nil)

                    Text("更新日 \(store.work.updatedAt.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 4)

                if isBodyEmpty {
                    Text("この作品にはまだメモがありません。")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if let summary = store.work.summary, !summary.isEmpty {
                    DetailSection(title: "概要", bodyText: summary)
                }

                if let styleMemo = store.work.styleMemo, !styleMemo.isEmpty {
                    DetailSection(title: "スタイルメモ", bodyText: styleMemo)
                }

                if let theme = store.work.theme, !theme.isEmpty {
                    DetailSection(title: "テーマ", bodyText: theme)
                }

                Spacer()
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.vertical, 32)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    store.send(.startEditing)
                } label: {
                    Label("編集", systemImage: "pencil")
                }
            }
        }
    }

    private var isBodyEmpty: Bool {
        [store.work.summary, store.work.styleMemo, store.work.theme]
            .compactMap(\.self)
            .allSatisfy(\.isEmpty)
    }
}

private struct DetailSection: View {
    let title: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(bodyText)
                .font(.body)
                .lineSpacing(4)
                .lineLimit(nil)
        }
    }
}

private struct EditWorkForm: View {
    let store: StoreOf<WorkDetailFeature>

    var body: some View {
        Form {
            Section("タイトル") {
                TextField(
                    "タイトルを入力してください",
                    text: Binding(
                        get: { store.editFormState.title },
                        set: { store.send(.updateFormTitle($0)) }
                    )
                )
            }

            Section("概要") {
                TextEditor(
                    text: Binding(
                        get: { store.editFormState.summary },
                        set: { store.send(.updateFormSummary($0)) }
                    )
                )
                .frame(minHeight: 80)
            }

            Section("スタイルメモ") {
                TextEditor(
                    text: Binding(
                        get: { store.editFormState.styleMemo },
                        set: { store.send(.updateFormStyleMemo($0)) }
                    )
                )
                .frame(minHeight: 80)
            }

            Section("テーマ") {
                TextEditor(
                    text: Binding(
                        get: { store.editFormState.theme },
                        set: { store.send(.updateFormTheme($0)) }
                    )
                )
                .frame(minHeight: 80)
            }

            if let errorMessage = store.errorMessage {
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                        Text(errorMessage)
                            .font(.caption)
                    }
                }
            }

            Section {
                HStack {
                    Button("キャンセル") {
                        store.send(.cancelEditing)
                    }
                    .foregroundStyle(.secondary)

                    Spacer()

                    Button("保存") {
                        store.send(.saveChanges)
                    }
                    .disabled(!store.editFormState.isFormValid)
                }
            }
        }
    }
}

private extension Color {
    static var workDetailBackground: Color {
        #if os(macOS)
        Color(nsColor: .textBackgroundColor)
        #else
        Color(.systemBackground)
        #endif
    }
}

#Preview {
    let sampleWork = Work(
        title: "サンプル作品",
        summary: "これはサンプルの概要です",
        styleMemo: "写実的な描写を心がける",
        theme: "成長と自己発見"
    )

    let store = Store(
        initialState: WorkDetailFeature.State(work: sampleWork),
        reducer: { WorkDetailFeature() }
    )

    WorkDetailView(store: store)
}
