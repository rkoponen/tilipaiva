import SwiftUI
import WidgetKit

/// The Tilipäivä widget.
///
/// This target shares the `Payday` engine with the app. Its payday content is
/// completed in the widget milestone; for now it renders a placeholder so the
/// target, App Group, and shared code all build and embed correctly.
struct TilipaivaWidget: Widget {
    let kind = "TilipaivaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PaymentProvider()) { entry in
            PaymentWidgetView(entry: entry)
                .containerBackground(for: .widget) { PaymentBackground() }
        }
        .configurationDisplayName("Tilipäivä")
        .description("Shows the days until your next payday.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline])
    }
}
