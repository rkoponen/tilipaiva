import SwiftUI

/// The day count as a large number over its unit, or a single word when the
/// payment is today.
///
/// The hero countdown and the Lock Screen circular widget share this view. The
/// unit always sits under the number: a phrase like "6 days" at hero size is
/// wider than the ring it would sit in, and stacking keeps the number centred on
/// its own axis instead of pushing it off-centre beside the unit.
struct CountdownDayView: View {
    let days: Int

    /// The font of the day number.
    var numberFont: Font = .system(.title, design: .rounded, weight: .semibold)

    /// The font of the unit label under the number.
    var unitFont: Font = .caption2

    /// Which wording the unit label uses.
    var unitStyle: UnitStyle = .full

    /// The font of the word shown when the payment is today. It is set apart from
    /// `numberFont` because a word is wider than a number and has to stay inside
    /// the same circle.
    var todayFont: Font = .headline

    /// How much room the unit word has to fit in.
    enum UnitStyle {
        /// The whole word, which the hero's ring has room for.
        case full

        /// A short form for the Lock Screen circular widget, where the Finnish
        /// "päivää" is wider than the circle it would sit in.
        case short
    }

    var body: some View {
        if days == 0 {
            Text("Today!")
                .font(todayFont)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        } else {
            VStack(spacing: 0) {
                Text(days, format: .number)
                    .font(numberFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(unitKey)
                    .font(unitFont)
            }
        }
    }

    /// The unit label to show under the number.
    ///
    /// A unit label carries no number, so the plural has to be chosen by hand;
    /// "1 days" would be wrong in English.
    private var unitKey: LocalizedStringKey {
        switch unitStyle {
        case .full: days == 1 ? "day" : "days"
        case .short: days == 1 ? "day (short)" : "days (short)"
        }
    }
}

#Preview("Widget", traits: .sizeThatFitsLayout) {
    HStack {
        CountdownDayView(days: 6)
        CountdownDayView(days: 1)
        CountdownDayView(days: 0)
    }
    .frame(width: 64, height: 64)
    .background(.black, in: .circle)
    .padding()
}

#Preview("Hero") {
    let heroNumber = Font.system(size: 88, weight: .semibold, design: .rounded)
    let heroUnit = Font.system(.title3, design: .rounded)

    return VStack(spacing: 40) {
        CountdownDayView(days: 6, numberFont: heroNumber, unitFont: heroUnit)
        CountdownDayView(days: 1, numberFont: heroNumber, unitFont: heroUnit)
        CountdownDayView(days: 0, numberFont: heroNumber, todayFont: .largeTitle)
    }
    .padding()
}
