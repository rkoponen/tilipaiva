import SwiftUI

/// A short burst of confetti for the first opening of the app on a payday.
///
/// It is drawn over the hero rather than in place of it: the countdown already
/// says "Today!" and names the payment, so the confetti only has to add the
/// moment. It carries no text, which is also why it needs no localization. It is
/// decoration, so assistive technologies skip it and it never takes a tap.
///
/// With Reduce Motion the pieces do not fall: they appear where they are and
/// fade in, so the moment still lands without anything moving across the screen.
struct PaydayCelebrationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The pieces, laid out once for the life of the view.
    @State private var particles = ConfettiParticle.burst()

    /// Whether the pieces have started to fall, or — with Reduce Motion — to
    /// appear.
    @State private var isRevealed = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle)
                        .rotationEffect(.degrees(isRevealed ? particle.spin : 0))
                        .position(
                            x: proxy.size.width * particle.x,
                            y: proxy.size.height * verticalPosition(of: particle)
                        )
                        .opacity(pieceOpacity)
                        .animation(.easeIn(duration: particle.duration).delay(particle.delay), value: isRevealed)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .task {
            isRevealed = true
        }
    }

    /// The vertical position of a piece as a fraction of the view's height, from
    /// 0 at the top to 1 at the bottom.
    ///
    /// A falling piece starts above the view and leaves below it, so it never has
    /// to fade; with Reduce Motion it holds its resting place instead.
    private func verticalPosition(of particle: ConfettiParticle) -> Double {
        guard !reduceMotion else { return particle.restingY }
        return isRevealed ? 1.15 : -0.15
    }

    /// Whether the pieces are drawn. The ones that fall are outside the view
    /// while they are hidden, so they can stay opaque the whole way; with Reduce
    /// Motion they appear in place and fade in with their own stagger.
    private var pieceOpacity: Double {
        reduceMotion && !isRevealed ? 0 : 1
    }
}

#Preview {
    PaydayCelebrationView()
        .background { PaymentBackground().ignoresSafeArea() }
}
