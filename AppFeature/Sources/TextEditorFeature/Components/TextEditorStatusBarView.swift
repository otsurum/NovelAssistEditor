import Extension
import SwiftUI

struct TextEditorStatusBarView: View {
    static let height: CGFloat = 24

    let cursorLine: Int
    let cursorColumn: Int
    let characterCount: Int
    let viewportWidth: CGFloat

    var body: some View {
        HStack(spacing: 16) {
            Text("行: \(cursorLine) 列: \(cursorColumn)")

            Spacer()

            Text("\(characterCount) 文字")
        }
        .font(.system(size: 12, weight: .medium).monospacedDigit())
        .padding(.horizontal, 8)
        .frame(height: Self.height)
        .foregroundStyle(.white.opacity(0.82))
        .background(Color.manuscriptStatusBarBackground)
    }
}
