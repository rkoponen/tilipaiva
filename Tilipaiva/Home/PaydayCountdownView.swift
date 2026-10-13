import SwiftUI

/// The hero countdown to the next payment, or an empty state when nothing is tracked.
struct PaydayCountdownView: View {
    let payment: UpcomingPayment?

    @ScaledMetric(relativeTo: .largeTitle) private var numberSize = Design.heroNumberSize

    var body: some View {
        if let payment {
            VStack(spacing: 8) {
                DaysUntilText(days: payment.daysUntil())
                    .font(.system(size: numberSize, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)

                Text(payment.title)
                    .font(.title3)

                Text(payment.date, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
        } else {
            ContentUnavailableView(
                "No payment sources yet",
                systemImage: "calendar.badge.plus",
                description: Text("Add a salary or Kela benefit to see your next payday.")
            )
        }
    }
}

#Preview("Payment") {
    PaydayCountdownView(payment: UpcomingPayment(
        source: PaymentSource(
            kind: .benefit,
            rule: .fixedDayOfMonth(day: 26, shift: .previousBankingDay, alsoShiftOnWeekdays: [.monday]),
            benefitID: Benefit.ID(rawValue: "lapsilisa")
        ),
        occurrence: PaymentOccurrence(sourceID: UUID(), date: .now)
    ))
    .padding()
}

#Preview("Empty") {
    PaydayCountdownView(payment: nil)
}
