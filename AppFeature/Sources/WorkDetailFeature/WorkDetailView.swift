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
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("作品を編集")
                        .font(.largeTitle.weight(.bold))
                        .lineLimit(1)

                    Text(store.work.updatedAt.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 2)

                VStack(alignment: .leading, spacing: 18) {
                    WorkTitleEditField(
                        text: Binding(
                            get: { store.editFormState.title },
                            set: { store.send(.updateFormTitle($0)) }
                        )
                    )

                    WorkTextEditField(
                        title: "概要",
                        systemImage: "text.alignleft",
                        text: Binding(
                            get: { store.editFormState.summary },
                            set: { store.send(.updateFormSummary($0)) }
                        ),
                        minHeight: 120
                    )

                    WorkTextEditField(
                        title: "スタイルメモ",
                        systemImage: "pencil.line",
                        text: Binding(
                            get: { store.editFormState.styleMemo },
                            set: { store.send(.updateFormStyleMemo($0)) }
                        ),
                        minHeight: 120
                    )

                    WorkTextEditField(
                        title: "テーマ",
                        systemImage: "lightbulb",
                        text: Binding(
                            get: { store.editFormState.theme },
                            set: { store.send(.updateFormTheme($0)) }
                        ),
                        minHeight: 96
                    )
                }

                if let errorMessage = store.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                HStack(spacing: 12) {
                    Button("キャンセル") {
                        store.send(.cancelEditing)
                    }
                    .keyboardShortcut(.cancelAction)

                    Spacer()

                    Button("保存") {
                        store.send(.saveChanges)
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .disabled(!store.editFormState.isFormValid)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.vertical, 32)
        }
        .background(Color.workDetailBackground)
    }
}

private struct WorkTitleEditField: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("タイトル", systemImage: "textformat")
                .font(.headline)
                .foregroundStyle(.secondary)

            TextField("タイトル", text: $text)
                .font(.title3.weight(.semibold))
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.workEditorBackground)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.workEditorBorder, lineWidth: 1)
                }
        }
    }
}

private struct WorkTextEditField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    let minHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.secondary)

            TextEditor(text: $text)
                .workEditorStyle(minHeight: minHeight)
        }
    }
}

private struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.caption)
                .foregroundStyle(.primary)

            Spacer(minLength: 0)
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.12))
        }
    }
}

private extension View {
    func workEditorStyle(minHeight: CGFloat = 88) -> some View {
        self
            .scrollContentBackground(.hidden)
            .frame(minHeight: minHeight)
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.workEditorBackground)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.workEditorBorder, lineWidth: 1)
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

    static var workEditorBackground: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color(.secondarySystemBackground)
        #endif
    }

    static var workEditorBorder: Color {
        #if os(macOS)
        Color(nsColor: .separatorColor).opacity(0.7)
        #else
        Color(.separator).opacity(0.7)
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
