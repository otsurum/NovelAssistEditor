import SwiftUI

@MainActor
final class TextInputCommitController {
    fileprivate var commitHandler: (() -> Void)?

    func commitEditing() {
        commitHandler?()
    }
}

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
        let commitController: TextInputCommitController
        let commitText: (String) -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text, commitText: commitText)
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
            context.coordinator.registerCommitController(commitController, for: textView)

            DispatchQueue.main.async {
                context.coordinator.updateObservedWindow(for: textView)
                textView.window?.makeFirstResponder(textView)
            }

            return textView
        }

        func updateNSView(_ textView: NSTextView, context: Context) {
            context.coordinator.commitText = commitText
            context.coordinator.registerCommitController(commitController, for: textView)
            context.coordinator.updateObservedWindow(for: textView)

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

        static func dismantleNSView(_ textView: NSTextView, coordinator: Coordinator) {
            coordinator.commitEditing(from: textView)
            coordinator.unregisterCommitController()
            coordinator.stopObservingWindow()
        }

        private var manuscriptFont: NSFont {
            NSFont(name: "Hiragino Mincho ProN", size: fontSize)
                ?? NSFont.systemFont(ofSize: fontSize)
        }

        @MainActor
        final class Coordinator: NSObject, NSTextViewDelegate {
            @Binding var text: String
            var commitText: (String) -> Void
            weak var textView: NSTextView?
            var lastFocusRequestID = 0
            private var lastCommittedText: String
            private weak var commitController: TextInputCommitController?
            private weak var observedWindow: NSWindow?

            init(text: Binding<String>, commitText: @escaping (String) -> Void) {
                _text = text
                self.commitText = commitText
                lastCommittedText = text.wrappedValue
                super.init()
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(applicationWillResignActive(_:)),
                    name: NSApplication.willResignActiveNotification,
                    object: nil
                )
            }

            deinit {
                NotificationCenter.default.removeObserver(self)
            }

            func registerCommitController(
                _ commitController: TextInputCommitController,
                for textView: NSTextView
            ) {
                self.commitController = commitController
                commitController.commitHandler = { [weak self, weak textView] in
                    guard let self, let textView else { return }
                    self.commitEditing(from: textView)
                }
            }

            func unregisterCommitController() {
                commitController?.commitHandler = nil
                commitController = nil
            }

            func updateObservedWindow(for textView: NSTextView) {
                guard observedWindow !== textView.window else { return }

                if let observedWindow {
                    NotificationCenter.default.removeObserver(
                        self,
                        name: NSWindow.didResignKeyNotification,
                        object: observedWindow
                    )
                }

                observedWindow = textView.window

                if let observedWindow {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(windowDidResignKey(_:)),
                        name: NSWindow.didResignKeyNotification,
                        object: observedWindow
                    )
                }
            }

            func stopObservingWindow() {
                if let observedWindow {
                    NotificationCenter.default.removeObserver(
                        self,
                        name: NSWindow.didResignKeyNotification,
                        object: observedWindow
                    )
                }
                observedWindow = nil
            }

            func textDidChange(_ notification: Notification) {
                guard let textView = notification.object as? NSTextView else { return }
                text = textView.string
            }

            func textShouldEndEditing(_ textObject: NSText) -> Bool {
                guard let textView = textObject as? NSTextView else { return true }
                commitEditing(from: textView)
                return true
            }

            func textDidEndEditing(_ notification: Notification) {
                guard let textView = notification.object as? NSTextView else { return }
                commitEditing(from: textView)
            }

            func commitEditing(from textView: NSTextView) {
                // IME composition can still be marked text when focus leaves the editor.
                if textView.hasMarkedText() {
                    textView.unmarkText()
                }

                let committedText = textView.string
                if text != committedText {
                    text = committedText
                }
                guard lastCommittedText != committedText else { return }

                lastCommittedText = committedText
                commitText(committedText)
            }

            @objc private func windowDidResignKey(_ notification: Notification) {
                guard let textView else { return }
                commitEditing(from: textView)
            }

            @objc private func applicationWillResignActive(_ notification: Notification) {
                guard let textView else { return }
                commitEditing(from: textView)
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
        let commitController: TextInputCommitController
        let commitText: (String) -> Void

        var body: some View {
            TextEditor(text: $text)
                .disabled(!isEditable)
                .font(.system(size: fontSize))
                .foregroundStyle(.white)
                .onDisappear {
                    commitText(text)
                }
        }
    }
#endif
