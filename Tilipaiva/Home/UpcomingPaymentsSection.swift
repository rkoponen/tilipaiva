import SwiftUI

/// The list of upcoming payments below the hero countdown.
struct UpcomingPaymentsSection: View {
    let payments: [UpcomingPayment]
    var onSelect: (PaymentSource) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Upcoming")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            ForEach(payments) { payment in
                Button {
                    onSelect(payment.source)
                } label: {
                    UpcomingPaymentRow(payment: payment)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Edit")

                if payment.id != payments.last?.id {
                    Divider()
                }
            }
        }
    }
}
