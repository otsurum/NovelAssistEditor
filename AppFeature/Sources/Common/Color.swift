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

    static var workContentHeaderBackground: Color {
        workContentSidebarBackground
    }

    static var workContentHeaderSeparator: Color {
        #if os(macOS)
            Color(nsColor: .separatorColor)
        #else
            Color(.separator)
        #endif
    }

    static var workContentSidebarBackground: Color {
        #if os(macOS)
            Color(nsColor: .underPageBackgroundColor)
        #else
            Color(.secondarySystemBackground)
        #endif
    }

    static var workDetailBackground: Color {
        appContentBackground
    }

    static var workEditorBackground: Color {
        #if os(macOS)
            Color(nsColor: .controlBackgroundColor)
        #else
            Color(.secondarySystemBackground)
        #endif
    }

    static var workEditorBorder: Color {
        #if os(macOS)
            Color(nsColor: .separatorColor).opacity(0.7)
        #else
            Color(.separator).opacity(0.7)
        #endif
    }

    static var workOverviewBackground: Color {
        appContentBackground
    }

    static var workOverviewPreviewBackground: Color {
        workEditorBackground
    }

    private static var appContentBackground: Color {
        #if os(macOS)
            Color(nsColor: .textBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
    }
}
