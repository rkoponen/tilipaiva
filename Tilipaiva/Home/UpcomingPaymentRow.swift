import SwiftUI

/// One row in the upcoming payments list.
struct UpcomingPaymentRow: View {
    let payment: UpcomingPayment

    var body: some View {
        HStack(spacing: 12) {
            Text(payment.title)
                .font(.body)

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 2) {
                DaysUntilText(days: payment.daysUntil())
                    .font(.subheadline)
                Text(payment.date, format: .dateTime.day().month(.wide))
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
        .contentShape(.rect)
    }
}

#Preview {
    VStack(spacing: 0) {
        UpcomingPaymentRow(payment: UpcomingPayment(
            source: PaymentSource.salary(name: "Palkka", rule: .fixedDayOfMonth(day: 15, shift: .none, alsoShiftOnWeekdays: [])),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now)
        ))
        Divider()
        UpcomingPaymentRow(payment: UpcomingPayment(
            source: PaymentSource(
                kind: .benefit,
                rule: .fixedDayOfMonth(day: 26, shift: .previousBankingDay, alsoShiftOnWeekdays: [.monday]),
                benefitID: Benefit.ID(rawValue: "lapsilisa")
            ),
            occurrence: PaymentOccurrence(sourceID: UUID(), date: .now)
        ))
    }
    .padding()
}
