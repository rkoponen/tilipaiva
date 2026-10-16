import SwiftUI

/// The hero countdown to the next payment, with the wait shown as a ring, a bar
/// or nothing at all.
///
/// The ring holds only how long the wait is; which payment it is and when it
/// arrives sit underneath, so the ring is not crammed full of text.
struct PaydayCountdownView: View {
    let payment: UpcomingPayment
    /// The wait the payment ends, when the source has an earlier payment to
    /// measure it from.
    let cycle: PaymentCycle?
    let progressStyle: ProgressStyle

    @ScaledMetric(relativeTo: .largeTitle) private var numberSize = Design.heroNumberSize
    @ScaledMetric(relativeTo: .largeTitle) private var ringSize = Design.heroRingSize

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if drawsRing, let fraction {
                    PaymentRing(fraction: fraction)
                        .frame(width: ringSize, height: ringSize)
                }

                CountdownDayView(
                    days: payment.daysUntil(),
                    numberFont: .system(size: numberSize, weight: .semibold, design: .rounded),
                    unitFont: .system(.title3, design: .rounded),
                    todayFont: .largeTitle,
                    stacksUnit: drawsRing
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

    /// Whether a ring is actually drawn: the style has to ask for one *and* the
    /// wait has to be known. Without a ring the unit shares the number's line.
    private var drawsRing: Bool {
        progressStyle == .ring && fraction != nil
    }
}

#Preview("Ring") {
    PaydayCountdownView(
        payment: .preview,
        cycle: PaymentCycle(previous: .now.addingTimeInterval(-15 * 86_400), next: .now.addingTimeInterval(15 * 86_400)),
        progressStyle: .ring
    )
    .padding()
}

#Preview("Ring, a long name") {
    PaydayCountdownView(
        payment: .longName,
        cycle: PaymentCycle(previous: .now.addingTimeInterval(-15 * 86_400), next: .now.addingTimeInterval(15 * 86_400)),
        progressStyle: .ring
    )
    .padding()
}

#Preview("None") {
    PaydayCountdownView(
        payment: .preview,
        cycle: PaymentCycle(previous: .now.addingTimeInterval(-15 * 86_400), next: .now.addingTimeInterval(15 * 86_400)),
        progressStyle: .none
    )
    .padding()
}

#Preview("Today") {
    PaydayCountdownView(payment: .today, cycle: PaymentCycle(previous: .now, next: .now), progressStyle: .ring)
        .padding()
}

#Preview("No cycle yet") {
    PaydayCountdownView(payment: .preview, cycle: nil, progressStyle: .ring)
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
