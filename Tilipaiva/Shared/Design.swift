import SwiftUI

/// Shared design constants, so the app's look stays consistent.
enum Design {
    /// The point size of the hero countdown at the standard text size. Views that
    /// use it scale it with Dynamic Type through `@ScaledMetric`.
    static let heroNumberSize: Double = 88

    /// The diameter of the hero's progress ring at the standard text size. It
    /// only has to enclose the day count, since the payment's name and date sit
    /// below it.
    static let heroRingSize: Double = 240

    /// The stroke width of the hero's progress ring.
    static let ringLineWidth: Double = 12

    /// The corner radius for cards and grouped content.
    static let cornerRadius: Double = 16

    /// The spacing between stacked sections on the home screen.
    static let sectionSpacing: Double = 24
}
