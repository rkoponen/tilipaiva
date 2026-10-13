import SwiftUI

/// The Lock Screen circular widget's content: the day count with a unit label
/// beneath it, or a single word when the payment is today.
struct CircularCountdownView: View {
    let days: Int

    var body: some View {
        if days == 0 {
            Text("Today!")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        } else {
            VStack(spacing: 0) {
                Text(days, format: .number)
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text("days")
                    .font(.caption2)
            }
        }
    }
}

#Preview {
    HStack {
        CircularCountdownView(days: 7)
        CircularCountdownView(days: 0)
    }
    .frame(width: 64, height: 64)
    .background(.black, in: .circle)
    .padding()
}
