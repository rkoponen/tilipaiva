import SwiftUI
import WidgetKit

struct PaymentWidgetView: View {
    let entry: PaymentEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if let payment = entry.payment {
                let days = payment.daysUntil(from: entry.date)

                switch family {
                case .accessoryCircular:
                    CircularCountdownView(days: days)

                case .accessoryInline:
                    // One line, with the countdown last: the line truncates from
                    // the end, so a long payment name gives way to the countdown,
                    // which is what the widget is for.
                    HStack(spacing: 4) {
                        Text(payment.title)
                            .lineLimit(1)

                        Text(verbatim: "·")

                        DaysUntilText(days: days)
                            .layoutPriority(1)
                    }

                case .accessoryRectangular:
                    RectangularCountdownView(payment: payment, days: days)

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
        .containerBackground(for: .widget) {
            WidgetBackground(family: family)
        }
    }
}
