//
//  WorkList.swift
//  AppFeature
//
//  Created by 鶴見駿 on 2026/04/27.
//

import AppCore
import ComposableArchitecture
import SwiftUI

public struct WorkList: View {
    let store: StoreOf<WorkListFeature>

    public init(store: StoreOf<WorkListFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.works.isEmpty {
                ContentUnavailableView(
                    "作品がありません",
                    systemImage: "book.closed",
                    description: Text("まずは作品を1つ作成してください。")
                )
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.works) { work in
                            WorkCard(work: work)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct WorkCard: View {
    let work: Work

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(work.title)
                .font(.headline)
                .lineLimit(1)

            if let summary = work.summary, !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                if let styleMemo = work.styleMemo, !styleMemo.isEmpty {
                    Label(styleMemo, systemImage: "pencil.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                }

                if let theme = work.theme, !theme.isEmpty {
                    Label(theme, systemImage: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .lineLimit(1)
                }

                Spacer()

                Text(work.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBrown))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
