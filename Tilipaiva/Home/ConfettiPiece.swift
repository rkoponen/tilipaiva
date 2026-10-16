import SwiftUI

/// A single piece of confetti: a euro sign or a small flake, tinted with the
/// brand green.
struct ConfettiPiece: View {
    let particle: ConfettiParticle

    var body: some View {
        Group {
            if particle.isEuro {
                // The euro sign is a symbol rather than a `Text`, so it stays out
                // of the string catalog: it is decoration, not a string to
                // translate.
                Image(systemName: "eurosign")
                    .font(.system(size: particle.size, weight: .bold, design: .rounded))
            } else {
                RoundedRectangle(cornerRadius: particle.size / 4, style: .continuous)
                    .frame(width: particle.size * 0.45, height: particle.size)
            }
        }
        .foregroundStyle(particle.tint)
    }
}

#Preview {
    HStack(spacing: 16) {
        ConfettiPiece(particle: .previewEuro)
        ConfettiPiece(particle: .previewFlake)
    }
    .padding()
}

private extension ConfettiParticle {
    static var previewEuro: Self {
        ConfettiParticle(
            id: 0, x: 0.5, restingY: 0.5, duration: 1, delay: 0, spin: 0,
            size: 22, isEuro: true, tint: .accentColor
        )
    }

    static var previewFlake: Self {
        ConfettiParticle(
            id: 1, x: 0.5, restingY: 0.5, duration: 1, delay: 0, spin: 0,
            size: 22, isEuro: false, tint: .accentColor.opacity(0.4)
        )
    }
}
