import SwiftUI

#if os(macOS)
    import AppKit
#endif

public extension Color {
    static var characterCardAccent: Color {
        #if os(macOS)
            Color(nsColor: .controlAccentColor)
        #else
            Color(.systemTeal)
        #endif
    }

    static var characterCardBackground: Color {
        #if os(macOS)
            Color(nsColor: .controlAccentColor).opacity(0.10)
        #else
            Color(.systemTeal).opacity(0.10)
        #endif
    }

    static var characterCardBorder: Color {
        #if os(macOS)
            Color(nsColor: .controlAccentColor).opacity(0.34)
        #else
            Color(.systemTeal).opacity(0.34)
        #endif
    }

    static var characterCardListBackground: Color {
        appContentBackground
    }

    static var characterDetailBackground: Color {
        appContentBackground
    }

    static var storyListBackground: Color {
        appContentBackground
    }

    static var storyListLink: Color {
        #if os(macOS)
            Color(nsColor: .linkColor)
        #else
            Color(.link)
        #endif
    }

    static var workDetailBackground: Color {
        appContentBackground
    }

    static var workOverviewBackground: Color {
        appContentBackground
    }

    static var workOverviewPreviewBackground: Color {
        #if os(macOS)
            Color(nsColor: .controlBackgroundColor)
        #else
            Color(.secondarySystemBackground)
        #endif
    }

    static var manuscriptViewBackground: Color {
        #if os(macOS)
            Color(nsColor: .underPageBackgroundColor)
        #else
            Color(.systemGroupedBackground)
        #endif
    }

    static var manuscriptPaperBackground: Color {
        #if os(macOS)
            Color(nsColor: .white)
        #else
            Color(.white)
        #endif
    }

    static var manuscriptRulerBackground: Color {
        #if os(macOS)
            Color(nsColor: .darkGray)
        #else
            Color(.darkGray)
        #endif
    }

    static var manuscriptStatusBarBackground: Color {
        #if os(macOS)
            Color(nsColor: .darkGray)
        #else
            Color(.darkGray)
        #endif
    }

    static var manuscriptPageBackground: Color {
        #if os(macOS)
            Color(nsColor: .textBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
    }

    static var manuscriptEditorBackground: Color {
        appContentBackground
    }

    private static var appContentBackground: Color {
        #if os(macOS)
            Color(nsColor: .textBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
    }
}
