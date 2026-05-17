import AppCore
import ComposableArchitecture
import SwiftUI

public struct CreateChapterFormState: Equatable {
    var episodeTitle = ""

    var isValid: Bool {
        !episodeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct CreateChapterModal: View {
    @Bindable var store: StoreOf<StoryListFeature>

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("エピソードタイトル", text: Binding(
                        get: { store.createForm.episodeTitle },
                        set: { store.send(.updateCreateFormTitle($0)) }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
            }
            .navigationTitle("新規エピソード")
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
