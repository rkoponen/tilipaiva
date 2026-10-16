import Foundation

/// How the hero countdown shows the wait for the next payment.
nonisolated enum ProgressStyle: String, Sendable {
    /// A ring around the countdown.
    case ring

    /// The countdown alone.
    case none
}
