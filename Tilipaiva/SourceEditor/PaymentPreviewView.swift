import SwiftUI

/// Previews the next few payment dates produced by a rule.
struct PaymentPreviewView: View {
    let rule: PaymentRule

    private var dates: [Date] {
        let source = PaymentSource(kind: .salary, rule: rule)
        return PaymentResolver().occurrences(for: source, onOrAfter: .now, count: 3).map(\.date)
    }

    var body: some View {
        if dates.isEmpty {
            Text("No payments")
                .foregroundStyle(.secondary)
        } else {
            ForEach(dates, id: \.self) { date in
                Text(date, format: .dateTime.weekday(.wide).day().month(.wide))
            }
        }
    }
}
