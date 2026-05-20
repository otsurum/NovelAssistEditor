import SwiftUI

#if os(macOS)
    import AppKit
#endif

#if os(macOS)
    struct VerticalTextInput: NSViewRepresentable {
        @Binding var text: String
        let isEditable: Bool
        let focusRequestID: Int
        let lineLength: CGFloat
        let fontSize: CGFloat

        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text)
        }

        func makeNSView(context: Context) -> NSTextView {
            let textView = NSTextView(frame: .zero)
            textView.delegate = context.coordinator
            textView.string = text
            textView.drawsBackground = false
            textView.isRichText = false
            textView.importsGraphics = false
            textView.allowsUndo = true
            textView.isEditable = isEditable
            textView.isSelectable = true
            textView.textColor = .white
            textView.insertionPointColor = .white
            textView.typingAttributes[.foregroundColor] = NSColor.white
            textView.font = manuscriptFont
            textView.layoutManager?.usesFontLeading = false
            textView.textContainerInset = .zero
            textView.setLayoutOrientation(.vertical)
            textView.isHorizontallyResizable = false
            textView.isVerticallyResizable = false
            textView.textContainer?.containerSize = NSSize(
                width: 0,
                height: lineLength
            )
            textView.textContainer?.heightTracksTextView = false
            textView.textContainer?.widthTracksTextView = true
            textView.textContainer?.lineFragmentPadding = 0

            context.coordinator.textView = textView
            context.coordinator.lastFocusRequestID = focusRequestID

            DispatchQueue.main.async {
                textView.window?.makeFirstResponder(textView)
            }

            return textView
        }

        func updateNSView(_ textView: NSTextView, context: Context) {
            if textView.string != text {
                let selectedRanges = textView.selectedRanges
                textView.string = text
                textView.selectedRanges = selectedRanges
            }

            textView.isEditable = isEditable
            textView.textColor = .white
            textView.insertionPointColor = .white
            textView.typingAttributes[.foregroundColor] = NSColor.white
            textView.font = manuscriptFont
            textView.layoutManager?.usesFontLeading = false
            textView.textContainerInset = .zero
            textView.textContainer?.containerSize = NSSize(
                width: max(textView.bounds.width, fontSize * 4),
                height: lineLength
            )
            textView.textContainer?.lineFragmentPadding = 0
            textView.textContainer?.heightTracksTextView = false
            textView.textContainer?.widthTracksTextView = true

            if context.coordinator.lastFocusRequestID != focusRequestID {
                context.coordinator.lastFocusRequestID = focusRequestID
                DispatchQueue.main.async {
                    textView.window?.makeFirstResponder(textView)
                }
            }
        }

        private var manuscriptFont: NSFont {
            NSFont(name: "Hiragino Mincho ProN", size: fontSize)
                ?? NSFont.systemFont(ofSize: fontSize)
        }

        final class Coordinator: NSObject, NSTextViewDelegate {
            @Binding var text: String
            weak var textView: NSTextView?
            var lastFocusRequestID = 0

            init(text: Binding<String>) {
                _text = text
            }

            func textDidChange(_ notification: Notification) {
                guard let textView = notification.object as? NSTextView else { return }
                text = textView.string
            }
        }
    }
#else
    struct VerticalTextInput: View {
        @Binding var text: String
        let isEditable: Bool
        let focusRequestID: Int
        let lineLength: CGFloat
        let fontSize: CGFloat

        var body: some View {
            TextEditor(text: $text)
                .disabled(!isEditable)
                .font(.system(size: fontSize))
                .foregroundStyle(.white)
        }
    }
#endif
