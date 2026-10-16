import SwiftUI
import WidgetKit

/// The Lock Screen rectangular widget: which payment is coming, and how long the
/// wait for it is.
///
/// The card is two lines — the payment's name, and the countdown below it in the
/// rounded design the hero's count uses — and both sit a step below the sizes
/// they wear elsewhere, so the card reads quietly on the Lock Screen.
///
/// The countdown shares the card with the count alone: the date used to sit
/// beside it, and the two competed for the line until the count, the one thing
/// the card is for, was the part that gave way ("3 p…").
struct RectangularCountdownView: View {
    let payment: UpcomingPayment

    /// The number of whole days from the entry's day to the payment.
    let days: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(payment.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)

            DaysUntilText(days: days)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

#Preview(as: .accessoryRectangular) {
    TilipaivaWidget()
} timeline: {
    // A payment still a week out.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Palkka", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(6 * 86_400))
        )
    )

    // A name long enough to test the wrapping.
    PaymentEntry(
        date: .now,
        payment: UpcomingPayment(
            source: .salary(name: "Joustava hoitoraha ja osittainen hoitoraha", rule: .lastBankingDayOfMonth),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now.addingTimeInterval(6 * 86_400))
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
