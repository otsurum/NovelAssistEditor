import ComposableArchitecture
import SwiftUI

public struct WorkListView: View {
    let store: StoreOf<WorkListFeature>

    public init(store: StoreOf<WorkListFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
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
                    List(store.works) { work in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(work.title)
                                .font(.headline)

                            if let summary = work.summary, !summary.isEmpty {
                                Text(summary)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("作品")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {} label: {
                        Label("新規作成", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        
                    } label: {
                        Label("再読み込み", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }
}
