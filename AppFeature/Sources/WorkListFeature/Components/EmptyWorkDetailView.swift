import SwiftUI

struct EmptyWorkDetailView: View {
    var body: some View {
        ContentUnavailableView(
            "作品を選択",
            systemImage: "text.book.closed",
            description: Text("左のサイドバーから作品を選んでください。")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
