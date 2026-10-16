import SwiftUI

/// One piece of confetti: where it falls, how it turns, and what it looks like.
///
/// The pieces are drawn from a seeded generator rather than the system one, so
/// the burst is scattered but identical on every launch: a preview and a
/// screenshot stay comparable with the last one.
struct ConfettiParticle: Identifiable {
    let id: Int

    /// The horizontal position across the view, from 0 to 1.
    let x: Double

    /// Where the piece rests when it does not fall, from 0 at the top of the
    /// view to 1 at the bottom. Used when Reduce Motion is on.
    let restingY: Double

    /// How long the piece takes to fall.
    let duration: Double

    /// How long the piece waits before it starts, so the burst is not a single
    /// straight line.
    let delay: Double

    /// How far the piece turns on its way down.
    let spin: Double

    /// The size of the piece in points.
    let size: Double

    /// Whether the piece is a euro sign; the rest are plain flakes.
    let isEuro: Bool

    /// The tint of the piece.
    let tint: Color

    /// A scattered handful of pieces, the same on every launch.
    static func burst(count: Int = 32) -> [ConfettiParticle] {
        var generator = SeededGenerator(seed: 0x7201_1210)
        // Tones of the brand green rather than a party palette, so the burst
        // reads as this app's moment and not as a generic confetti layer.
        let tints: [Color] = [.accentColor, .accentColor.opacity(0.7), .accentColor.opacity(0.45)]

        return (0..<count).map { index in
            let isEuro = index % 3 == 0
            return ConfettiParticle(
                id: index,
                x: Double.random(in: 0.05...0.95, using: &generator),
                restingY: Double.random(in: 0.15...0.85, using: &generator),
                // The waits stay short, and the falls are slow enough to read:
                // the pieces should drift down rather than snap past the hero.
                duration: Double.random(in: 1.7...2.5, using: &generator),
                delay: Double.random(in: 0...0.35, using: &generator),
                // A flake tumbles on the way down; a euro sign only leans, since
                // a currency symbol on its head reads as a scrambled glyph.
                spin: isEuro
                    ? Double.random(in: -25...25, using: &generator)
                    : Double.random(in: -540...540, using: &generator),
                size: Double.random(in: 12...22, using: &generator),
                isEuro: isEuro,
                tint: tints[index % tints.count]
            )
        }
    }
}

/// A tiny deterministic generator, good enough to scatter confetti.
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}
