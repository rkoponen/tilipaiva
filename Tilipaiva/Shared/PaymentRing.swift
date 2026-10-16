import SwiftUI

/// A ring that fills as the wait for the next payment passes.
///
/// It is decoration: the countdown inside it already says how long the wait is,
/// so assistive technologies skip it.
struct PaymentRing: View {
    /// How much of the wait has passed, from 0 to 1.
    let fraction: Double

    var lineWidth: Double = Design.ringLineWidth

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 24) {
        PaymentRing(fraction: 0).frame(width: 96, height: 96)
        PaymentRing(fraction: 0.5).frame(width: 96, height: 96)
        PaymentRing(fraction: 1).frame(width: 96, height: 96)
    }
    .padding()
}
