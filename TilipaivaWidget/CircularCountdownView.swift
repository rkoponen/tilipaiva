import SwiftUI
import WidgetKit

/// The Lock Screen circular widget: the day count, its unit, and the euro disc
/// the app icon wears, stacked the way the system's own small widgets stack a
/// number, its label and their mark.
///
/// The unit is abbreviated here — `CountdownDayView.UnitStyle.short` — because
/// the Finnish "päivää" is wider than the circle, and the countdown is inset so
/// "Tänään!" scales down instead of running over the edge.
struct CircularCountdownView: View {
    let days: Int

    var body: some View {
        VStack(spacing: 0) {
            CountdownDayView(
                days: days,
                numberFont: .system(.title2, design: .rounded, weight: .semibold),
                unitFont: .system(.caption2, design: .rounded),
                unitStyle: .short,
                todayFont: .system(.subheadline, design: .rounded, weight: .semibold)
            )

            Image(systemName: "eurosign.circle.fill")
                .font(.subheadline)
        }
        .padding(.horizontal, 6)
    }
}

#Preview(as: .accessoryCircular) {
    TilipaivaWidget()
} timeline: {
    // A few days out.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(3 * 86_400))
        )
    )

    // A single day, where the unit has to go singular.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(86_400))
        )
    )

    // Three digits.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(128 * 86_400))
        )
    )

    // The payment lands today.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now)
        )
    )
}
