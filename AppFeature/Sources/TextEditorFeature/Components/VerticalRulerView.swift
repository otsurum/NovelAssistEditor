import Extension
import SwiftUI

struct VerticalRulerView: View {
    let availableHeight: CGFloat
    private let markerCount = 40

    var body: some View {
        let markerHeight = availableHeight / CGFloat(markerCount + 1)

        ZStack(alignment: .topLeading) {
            Color.manuscriptRulerBackground

            Rectangle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 1)

            VStack(spacing: 0) {
                ForEach(0 ... markerCount, id: \.self) { index in
                    rulerMarker(index, height: markerHeight)
                }
            }
            .padding(.leading, 8)

            VStack(spacing: markerHeight * 2) {
                ForEach(0 ..< 8, id: \.self) { _ in
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 8))
                        .rotationEffect(.degrees(180))
                        .foregroundStyle(.white.opacity(0.36))
                }
            }
            .padding(.top, markerHeight)
            .padding(.leading, 38)
        }
    }

    private func rulerMarker(_ index: Int, height: CGFloat) -> some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.32 : 0.18))
                .frame(width: index.isMultiple(of: 2) ? 16 : 8, height: 1)

            if index.isMultiple(of: 2) {
                Text("\(index)")
                    .font(.system(size: 10, weight: .medium).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.72))
                    .rotationEffect(.degrees(90))
                    .frame(width: 18, height: 18)
            }
        }
        .frame(height: height, alignment: .topLeading)
    }
}
