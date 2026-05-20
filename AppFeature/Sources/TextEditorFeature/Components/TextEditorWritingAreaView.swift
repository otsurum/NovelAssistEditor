import AppCore
import Extension
import SwiftUI

struct TextEditorWritingAreaView: View {
    static let rulerWidth: CGFloat = 60

    let size: CGSize
    let manuscriptBody: ManuscriptBody
    @Binding var text: String
    let isEditorVisible: Bool
    let focusRequestID: Int

    static func viewportWidth(for size: CGSize) -> CGFloat {
        max(0, size.width - rulerWidth)
    }

    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Color.characterCardListBackground

                writingEditor

                if !isEditorVisible {
                    readOnlyOverlay
                }
            }

            VerticalRulerView(availableHeight: size.height)
                .frame(width: Self.rulerWidth)
        }
    }

    private var writingEditor: some View {
        let lineHeight = size.height / CGFloat(ManuscriptLine.maxCharacterCount + 1)
        let fontSize = max(8, lineHeight * 0.999)
        let columnPitch: CGFloat = 24
        let firstLineTrailingGutter: CGFloat = 2
        let firstCharacterTopOffset: CGFloat = 8
        let viewportWidth = Self.viewportWidth(for: size)
        let writingHeight = max(240, CGFloat(ManuscriptLine.maxCharacterCount) * lineHeight)
        let visibleLineCount = max(ManuscriptPage.maxLineCount, manuscriptBody.lineCount + 2)
        let writingWidth = max(320, CGFloat(visibleLineCount) * columnPitch + 48)
        let leadingSpacer = max(0, viewportWidth - writingWidth - firstLineTrailingGutter)

        return ScrollView([.horizontal, .vertical], showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                Spacer(minLength: leadingSpacer)

                VerticalTextInput(
                    text: $text,
                    isEditable: isEditorVisible,
                    focusRequestID: focusRequestID,
                    lineLength: CGFloat(ManuscriptLine.maxCharacterCount) * lineHeight,
                    fontSize: fontSize
                )
                .frame(width: writingWidth, height: writingHeight)
                .offset(y: firstCharacterTopOffset)

                Color.clear
                    .frame(width: firstLineTrailingGutter)
            }
            .frame(
                minWidth: viewportWidth,
                minHeight: max(0, size.height),
                alignment: .topLeading
            )
        }
        .defaultScrollAnchor(.topTrailing)
    }

    private var readOnlyOverlay: some View {
        Text("読取専用")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))
            .padding(.top, 18)
            .padding(.trailing, 84)
    }
}
