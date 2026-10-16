import CoreHaptics
import UIKit

/// The payday flourish: a short rise of taps that lands on one solid thump, with
/// two faint sparks after it.
///
/// The system's own feedback patterns are single events — `.success` is two even
/// taps — and the point of a payday is the rise, so the pattern is written out
/// here. Core Haptics plays it where the hardware supports it; if the engine will
/// not start, the same rhythm is played with `UIImpactFeedbackGenerator`s. The
/// celebration never depends on either: the tap is a bonus on top of what is on
/// screen, the system is free to drop it, and the switch in Settings turns it off
/// along with the confetti.
@MainActor
final class PaydayHaptics {
    static let shared = PaydayHaptics()

    /// The engine and the prepared pattern, kept for the life of the app: a cold
    /// engine takes long enough to start that the tap would arrive late.
    private var engine: CHHapticEngine?
    private var player: CHHapticPatternPlayer?

    private init() {}

    /// Builds the engine and the player ahead of the moment.
    func prepare() {
        guard engine == nil, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            let engine = try CHHapticEngine()
            // The system stops the engine when the app goes to the background,
            // and after a media services reset. Dropping what is stale is all
            // that is needed: the next `prepare()` builds it again.
            engine.stoppedHandler = { [weak self] _ in
                Task { @MainActor in self?.discard() }
            }
            engine.resetHandler = { [weak self] in
                Task { @MainActor in self?.discard() }
            }
            try engine.start()

            let pattern = try CHHapticPattern(events: Self.events(), parameters: [])
            player = try engine.makePlayer(with: pattern)
            self.engine = engine
        } catch {
            // No engine, no pattern: `play()` falls back to the generators.
            discard()
        }
    }

    /// Plays the flourish.
    func play() {
        if let engine, let player {
            do {
                try engine.start()
                try player.start(atTime: CHHapticTimeImmediate)
                return
            } catch {
                discard()
            }
        }
        playWithGenerators()
    }

    /// Throws away the engine and the player, so the next `prepare()` rebuilds
    /// them.
    private func discard() {
        engine = nil
        player = nil
    }

    /// The same rise without Core Haptics: four taps that get firmer, on the
    /// impact generators. The sparks are left out — a light impact is too dull to
    /// read as one.
    private func playWithGenerators() {
        let medium = UIImpactFeedbackGenerator(style: .medium)
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        medium.prepare()
        heavy.prepare()

        Task { @MainActor in
            for (index, tap) in Self.taps.enumerated() {
                let generator = index == Self.taps.count - 1 ? heavy : medium
                generator.impactOccurred(intensity: CGFloat(tap.intensity))
                guard index < Self.taps.count - 1 else { break }
                try? await Task.sleep(for: .milliseconds(120))
            }
        }
    }

    // MARK: - The pattern

    /// One tap of the pattern.
    private struct Tap {
        /// When it lands, in seconds from the start.
        let time: TimeInterval
        /// How hard it is.
        let intensity: Float
        /// How tight it feels: a low value is a dull knock, a high one a click.
        let sharpness: Float
    }

    /// The rise: four taps, each firmer and tighter than the last, spaced the way
    /// an ear reads a drumroll.
    private static let taps: [Tap] = [
        Tap(time: 0, intensity: 0.45, sharpness: 0.35),
        Tap(time: 0.12, intensity: 0.62, sharpness: 0.55),
        Tap(time: 0.24, intensity: 0.82, sharpness: 0.75),
        Tap(time: 0.36, intensity: 1, sharpness: 1),
    ]

    /// Two faint sparks after the landing, like glitter settling.
    private static let sparks: [Tap] = [
        Tap(time: 0.54, intensity: 0.35, sharpness: 1),
        Tap(time: 0.62, intensity: 0.2, sharpness: 1),
    ]

    /// The pattern as Core Haptics sees it.
    private static func events() -> [CHHapticEvent] {
        var events = transients(for: taps)

        // A short, dull body under the landing: it is what makes the last tap
        // feel like a thump rather than one more tap.
        events.append(
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: 0.7),
                    .init(parameterID: .hapticSharpness, value: 0.2),
                ],
                relativeTime: taps.last?.time ?? 0,
                duration: 0.22
            )
        )

        return events + transients(for: sparks)
    }

    private static func transients(for taps: [Tap]) -> [CHHapticEvent] {
        taps.map { tap in
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: tap.intensity),
                    .init(parameterID: .hapticSharpness, value: tap.sharpness),
                ],
                relativeTime: tap.time
            )
        }
    }
}
