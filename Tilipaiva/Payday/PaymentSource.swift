import Foundation

/// A recurring income the user tracks, such as a salary or a Kela benefit.
nonisolated struct PaymentSource: Identifiable, Hashable, Codable, Sendable {
    nonisolated enum Kind: String, Codable, Hashable, Sendable {
        case salary
        case benefit
    }

    var id: UUID
    var kind: Kind
    var rule: PaymentRule
    /// The catalog benefit this source tracks, when `kind` is `.benefit`.
    var benefitID: Benefit.ID?
    /// The user-chosen name, used when `kind` is `.salary`.
    var name: String

    init(
        id: UUID = UUID(),
        kind: Kind,
        rule: PaymentRule,
        benefitID: Benefit.ID? = nil,
        name: String = ""
    ) {
        self.id = id
        self.kind = kind
        self.rule = rule
        self.benefitID = benefitID
        self.name = name
    }

    /// A source for one of the bundled Kela benefits.
    static func benefit(_ benefit: Benefit) -> PaymentSource {
        PaymentSource(kind: .benefit, rule: benefit.rule, benefitID: benefit.id)
    }

    /// A salary source with a user-chosen name.
    static func salary(name: String, rule: PaymentRule) -> PaymentSource {
        PaymentSource(kind: .salary, rule: rule, name: name)
    }

    /// The localized display name, resolving benefit names from the catalog.
    ///
    /// A salary's name is the user's, and it is optional: a name left blank is
    /// shown as the word for the kind, so a row never reads as empty. The
    /// fallback is resolved when it is shown rather than when the source is
    /// saved, so it follows the app's language instead of the one the source
    /// happened to be added in.
    var title: String {
        if let benefitID, let benefit = BenefitCatalog.bundled.benefit(id: benefitID) {
            return benefit.name.value()
        }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? String(localized: "Salary") : trimmed
    }
}
