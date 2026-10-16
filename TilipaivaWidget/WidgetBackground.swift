import SwiftUI
import WidgetKit

/// The background a widget carries.
///
/// Only the home screen widgets wear the app's gradient. The Lock Screen
/// accessories sit on the wallpaper the way the system's own do, so they are
/// drawn on nothing.
struct WidgetBackground: View {
    let family: WidgetFamily

    var body: some View {
        if isOnLockScreen {
            Color.clear
        } else {
            PaymentBackground()
        }
    }

    private var isOnLockScreen: Bool {
        switch family {
        case .accessoryCircular, .accessoryInline, .accessoryRectangular: true
        default: false
        }
    }
}
