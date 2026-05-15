import AppCore
import SwiftUI

struct CreateCharacterFormState: Equatable {
    var name = ""
    var personality = ""
    var speechStyle = ""
    var background = ""

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct CreateCharacterModal: View {
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

extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
