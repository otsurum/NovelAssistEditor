import AppCore
import Extension
import SwiftUI

struct ManuscriptPageGridView: View {
    let lines: [ManuscriptLine]
    let pageNumber: Int
    var cellSize: CGFloat = 18

    private let columnCount = ManuscriptPage.maxLineCount
    private let rowCount = ManuscriptLine.maxCharacterCount

    var body: some View {
        VStack(spacing: 6) {
            pageGrid
            Text("\(pageNumber)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var pageGrid: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(0..<columnCount, id: \.self) { colIndex in
                columnView(at: colIndex)
            }
        }
        .background(Color.manuscriptPageBackground)
        .overlay {
            Rectangle()
                .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    private func columnView(at colIndex: Int) -> some View {
        let characters = characters(in: colIndex)

        return VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { rowIndex in
                Text(rowIndex < characters.count ? characters[rowIndex] : "")
                    .font(.system(size: cellSize * 0.72))
                    .foregroundStyle(Color.primary)
                    .frame(width: cellSize, height: cellSize)
                    .border(Color.secondary.opacity(0.1), width: 0.5)
            }
        }
    }

    private func characters(in column: Int) -> [String] {
        guard column < lines.count else { return [] }
        return lines[column].text.map(String.init)
    }
}
