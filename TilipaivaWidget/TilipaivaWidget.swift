import SwiftUI
import WidgetKit

/// The Tilipäivä widget.
///
/// This target shares the `Payday` engine with the app: the home screen sizes
/// show the countdown for the next payment, and the Lock Screen accessories show
/// it in the space they are given.
struct TilipaivaWidget: Widget {
    let kind = "TilipaivaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PaymentProvider()) { entry in
            PaymentWidgetView(entry: entry)
        }
        .configurationDisplayName("Tilipäivä")
        .description("Shows the days until your next payday.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}
