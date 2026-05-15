import AppCore
import SwiftUI

struct CreateChapterFormState: Equatable {
    var episodeTitle = ""

    var isValid: Bool {
        !episodeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct CreateChapterModal: View {
    @Binding var form: CreateChapterFormState
    let onCancel: () -> Void
    let onCreate: (Chapter) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("エピソードタイトル", text: $form.episodeTitle)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .navigationTitle("新規エピソード")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        onCreate(makeChapter())
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

    private func makeChapter() -> Chapter {
        Chapter(episodeTitle: form.episodeTitle.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
