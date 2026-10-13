import Foundation

/// A Kela benefit whose payment dates are computed from a rule.
nonisolated struct Benefit: Identifiable, Hashable, Codable, Sendable {
    nonisolated struct ID: Hashable, RawRepresentable, Codable, Sendable {
        let rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    let id: ID
    let name: LocalizedText
    let rule: PaymentRule
}
