import SwiftUI
import WidgetKit

/// The Lock Screen circular widget: the day count and its unit inside the ring
/// that shows how much of the wait has passed.
///
/// The ring is a `Gauge` with `.accessoryCircularCapacity` rather than a drawn
/// circle: the system's own thin ring is what the neighbouring Lock Screen
/// widgets wear, so the countdown sits in their company. That style ignores the
/// gauge's `label`, which is why the euro disc the app icon wears does not come
/// along — it would have to live in the value slot beside the count, and it
/// crowded the unit. The count is what the card is for.
///
/// The unit is abbreviated here — `CountdownDayView.UnitStyle.short` — because
/// the Finnish "päivää" is wider than the circle it would sit in.
struct CircularCountdownView: View {
    let days: Int

    /// How much of the wait has passed, from 0 to 1, or `nil` when the source
    /// has no earlier payment to measure it from. Without a wait there is no
    /// share to draw, and the count stands on its own, as it does in the hero.
    let fraction: Double?

    var body: some View {
        if let fraction {
            Gauge(value: fraction) {
                EmptyView()
            } currentValueLabel: {
                countdown
            }
            .gaugeStyle(.accessoryCircularCapacity)
        } else {
            countdown
        }
    }

    private var countdown: some View {
        CountdownDayView(
            days: days,
            numberFont: .system(.title3, design: .rounded, weight: .semibold),
            unitFont: .system(.caption2, design: .rounded),
            unitStyle: .short,
            todayFont: .system(.subheadline, design: .rounded, weight: .semibold)
        )
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
        ),
        cycle: PaymentCycle(previous: .now.addingTimeInterval(-27 * 86_400), next: .now.addingTimeInterval(3 * 86_400))
    )

    // A single day, where the unit has to go singular.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(86_400))
        ),
        cycle: PaymentCycle(previous: .now.addingTimeInterval(-29 * 86_400), next: .now.addingTimeInterval(86_400))
    )

    // Three digits.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(128 * 86_400))
        ),
        cycle: PaymentCycle(previous: .now.addingTimeInterval(-2 * 86_400), next: .now.addingTimeInterval(128 * 86_400))
    )

    // The payment lands today, so the ring is full.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now)
        ),
        cycle: PaymentCycle(previous: .now.addingTimeInterval(-30 * 86_400), next: .now)
    )

    // A source with no earlier payment: no wait, so no ring.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(3 * 86_400))
        ),
        cycle: nil
    )
}
