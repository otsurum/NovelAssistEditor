import AppCore
import ComposableArchitecture
import SwiftUI

public struct CreateCharacterFormState: Equatable {
    var name = ""
    var personality = ""
    var speechStyle = ""
    var background = ""

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct CreateCharacterModal: View {
    @Bindable var store: StoreOf<CharacterCardListFeature>

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("名前", text: Binding(
                        get: { store.createForm.name },
                        set: { store.send(.updateCreateFormName($0)) }
                    ))
                    .textFieldStyle(.roundedBorder)
                }

                Section(header: Text("設定資料")) {
                    TextField("性格", text: Binding(
                        get: { store.createForm.personality },
                        set: { store.send(.updateCreateFormPersonality($0)) }
                    ), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3 ... 5)

                    TextField("口調", text: Binding(
                        get: { store.createForm.speechStyle },
                        set: { store.send(.updateCreateFormSpeechStyle($0)) }
                    ), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3 ... 5)

                    TextField("背景", text: Binding(
                        get: { store.createForm.background },
                        set: { store.send(.updateCreateFormBackground($0)) }
                    ), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4 ... 8)
                }
            }
            .navigationTitle("新規キャラクター")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        store.send(.submitCreate)
                    }
                    .disabled(!store.createForm.isValid)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        store.send(.hideCreateModal)
                    }
                }
            }
        }
    }
}

extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
