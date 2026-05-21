import SwiftUI

public extension View {
    func workEditorStyle(minHeight: CGFloat = 88) -> some View {
        scrollContentBackground(.hidden)
            .frame(minHeight: minHeight)
            .padding(8)
    }
}
