import SwiftUI
import WidgetKit

struct PaymentWidgetView: View {
    let entry: PaymentEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let payment = entry.payment {
            let days = payment.daysUntil(from: entry.date)

            switch family {
            case .accessoryCircular:
                CountdownDayView(days: days)

            case .accessoryInline:
                DaysUntilText(days: days)

            default:
                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    DaysUntilText(days: days)
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)

                    Text(payment.date, format: .dateTime.weekday(.wide).day().month(.wide))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
        } else {
            Text("No payment sources yet")
        }
    }
}
