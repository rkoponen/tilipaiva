import SwiftUI

/// The hero countdown to the next payment, with the wait drawn as a ring.
///
/// The ring holds only how long the wait is; which payment it is and when it
/// arrives sit underneath, so the ring is not crammed full of text. A ring needs
/// a wait to measure, so when the source has no earlier payment to count from the
/// countdown stands on its own.
struct PaydayCountdownView: View {
    let payment: UpcomingPayment
    /// The wait the payment ends, when the source has an earlier payment to
    /// measure it from.
    let cycle: PaymentCycle?

    @ScaledMetric(relativeTo: .largeTitle) private var numberSize = Design.heroNumberSize
    @ScaledMetric(relativeTo: .largeTitle) private var ringSize = Design.heroRingSize

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if let fraction {
                    PaymentRing(fraction: fraction)
                        .frame(width: ringSize, height: ringSize)
                }

                CountdownDayView(
                    days: payment.daysUntil(),
                    numberFont: .system(size: numberSize, weight: .semibold, design: .rounded),
                    unitFont: .system(.title3, design: .rounded),
                    todayFont: .largeTitle
                )
            }

            VStack(spacing: 4) {
                Text(payment.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(payment.date, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    /// How much of the wait has passed, when the payment's cycle is known.
    private var fraction: Double? {
        cycle?.fraction()
    }
}

#Preview("Ring") {
    PaydayCountdownView(
        payment: .preview,
        cycle: PaymentCycle(previous: .now.addingTimeInterval(-15 * 86_400), next: .now.addingTimeInterval(15 * 86_400))
    )
    .padding()
}

#Preview("Ring, a long name") {
    PaydayCountdownView(
        payment: .longName,
        cycle: PaymentCycle(previous: .now.addingTimeInterval(-15 * 86_400), next: .now.addingTimeInterval(15 * 86_400))
    )
    .padding()
}

#Preview("Today") {
    PaydayCountdownView(payment: .today, cycle: PaymentCycle(previous: .now, next: .now))
        .padding()
}

#Preview("No cycle known") {
    PaydayCountdownView(payment: .preview, cycle: nil)
        .padding()
}

private extension UpcomingPayment {
    /// A sample payment for the previews in this file.
    static var preview: Self {
        UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(6 * 86_400))
        )
    }

    /// A sample payment with a name long enough to test the wrapping.
    static var longName: Self {
        UpcomingPayment(
            source: .salary(name: "Joustava hoitoraha ja osittainen hoitoraha", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(6 * 86_400))
        )
    }

    /// A sample payment that lands today.
    static var today: Self {
        UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now)
        )
    }
}
