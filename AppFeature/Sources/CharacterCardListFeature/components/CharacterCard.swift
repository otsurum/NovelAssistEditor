import AppCore
import Common
import SwiftUI

struct CharacterCard: View {
    let character: AppCore.Character

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.characterCardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.characterCardBorder, lineWidth: 1)
                    }

                HStack(alignment: .top, spacing: 0) {
                    Rectangle()
                        .fill(Color.characterCardAccent)
                        .frame(width: 5)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "person.crop.circle")
                                .font(.title3)
                                .foregroundStyle(Color.characterCardAccent)

                            Text(character.name)
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }

                        if let previewText {
                            Text(previewText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(4)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.characterCardBackground)
                    .shadow(color: Color.characterCardAccent.opacity(0.08), radius: 8, x: 0, y: 3)
            }
            .frame(width: 180, height: 134)

            HStack(spacing: 5) {
                Image(systemName: "person.text.rectangle")
                    .font(.caption2)

                Text(character.updatedAt.formatted(date: .numeric, time: .omitted))
                    .lineLimit(1)
            }
            .font(.caption)
            .foregroundStyle(Color.characterCardAccent)
            .frame(width: 180)
        }
        .frame(width: 180, alignment: .top)
        .contentShape(Rectangle())
    }

    private var previewText: String? {
        for text in [character.personality, character.speechStyle, character.background] {
            if let text, !text.isEmpty {
                return text
            }
        }
        return nil
    }
}
