import Foundation

/// Editable form of a `PaymentSource`.
struct SourceDraft: Equatable {
    let id: UUID
    var kind: PaymentSource.Kind
    var name: String
    var benefitID: Benefit.ID?
    var rule: RuleDraft

    init(_ source: PaymentSource) {
        self.id = source.id
        self.kind = source.kind
        self.name = source.name
        self.benefitID = source.benefitID
        self.rule = RuleDraft(source.rule)
    }

    /// The rule currently shown, taken from the chosen benefit when tracking one.
    var effectiveRule: PaymentRule {
        if kind == .benefit, let benefitID, let benefit = BenefitCatalog.bundled.benefit(id: benefitID) {
            return benefit.rule
        }
        return rule.rule
    }

    /// The source described by the current fields.
    var source: PaymentSource {
        switch kind {
        case .benefit:
            PaymentSource(id: id, kind: .benefit, rule: effectiveRule, benefitID: benefitID)
        case .salary:
            PaymentSource(id: id, kind: .salary, rule: rule.rule, name: name)
        }
    }
}
