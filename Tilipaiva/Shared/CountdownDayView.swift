import SwiftUI

/// The day count as a large number with its unit, or a single word when the
/// payment is today.
///
/// The hero countdown and the Lock Screen circular widget share this view. The
/// unit sits under the number when there is a ring around it — a phrase like
/// "6 days" is wider than the circle — and beside it on a plain line, where the
/// two read as one.
struct CountdownDayView: View {
    let days: Int

    /// The font of the day number.
    var numberFont: Font = .system(.title, design: .rounded, weight: .semibold)

    /// The font of the unit label.
    var unitFont: Font = .caption2

    /// The font of the word shown when the payment is today. It is set apart from
    /// `numberFont` because a word is wider than a number and has to stay inside
    /// the same circle.
    var todayFont: Font = .headline

    /// Whether the unit sits under the number, which is what fits inside a ring.
    var stacksUnit = true

    var body: some View {
        if days == 0 {
            Text("Today!")
                .font(todayFont)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        } else {
            // One pair of labels, two arrangements.
            let layout = stacksUnit
                ? AnyLayout(VStackLayout(spacing: 0))
                : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 8))

            layout {
                Text(days, format: .number)
                    .font(numberFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                // A unit label carries no number, so the plural has to be chosen
                // by hand; "1 days" would be wrong in English.
                Text(days == 1 ? "day" : "days")
                    .font(unitFont)
            }
        }
    }
}

#Preview {
    let heroNumber = Font.system(size: 88, weight: .semibold, design: .rounded)

    return VStack(spacing: 32) {
        CountdownDayView(days: 6)
        CountdownDayView(days: 6, numberFont: heroNumber, unitFont: .system(.title3, design: .rounded))
        CountdownDayView(
            days: 6,
            numberFont: heroNumber,
            unitFont: .system(.title3, design: .rounded),
            stacksUnit: false
        )
        CountdownDayView(days: 1, numberFont: heroNumber, unitFont: .system(.title3, design: .rounded), stacksUnit: false)
        CountdownDayView(days: 0, numberFont: heroNumber, todayFont: .largeTitle)
    }
    .padding()
}
