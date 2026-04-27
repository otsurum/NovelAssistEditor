//
//  CreateWorkModal.swift
//  AppFeature
//
//  Created by 鶴見駿 on 2026/04/17.
//

import AppCore
import ComposableArchitecture
import SwiftUI

public struct CreateWorkModal: View {
    let store: StoreOf<WorkListFeature>

    var isFormValid: Bool {
        !store.createModalForm.title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public init(store: StoreOf<WorkListFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("作品情報")) {
                    TextField("タイトル", text: .init(
                        get: { store.createModalForm.title },
                        set: { store.send(.updateFormTitle($0)) }
                    ))
                    .textFieldStyle(.roundedBorder)

                    TextField("要約", text: .init(
                        get: { store.createModalForm.summary },
                        set: { store.send(.updateFormSummary($0)) }
                    ), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3 ... 5)
                }

                Section(header: Text("執筆ノート")) {
                    TextField("文体メモ", text: .init(
                        get: { store.createModalForm.styleMemo },
                        set: { store.send(.updateFormStyleMemo($0)) }
                    ), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3 ... 5)

                    TextField("テーマ", text: .init(
                        get: { store.createModalForm.theme },
                        set: { store.send(.updateFormTheme($0)) }
                    ), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2 ... 3)
                }
            }
            .navigationTitle("新規作品")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("作成") {
                        store.send(.createWork)
                    }
                    .disabled(!isFormValid)
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
