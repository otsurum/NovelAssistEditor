import AppCore
import Common
import ComposableArchitecture
import SwiftUI

struct EditWorkForm: View {
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

struct WorkTitleEditField: View {
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

struct WorkTextEditField: View {
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

struct ErrorBanner: View {
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

extension View {
    func workEditorStyle(minHeight: CGFloat = 88) -> some View {
        scrollContentBackground(.hidden)
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
