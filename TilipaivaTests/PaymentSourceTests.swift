import Foundation
import Testing
@testable import Tilipaiva

struct PaymentSourceTests {
    @Test func aSalaryKeepsTheNameItWasGiven() {
        let source = PaymentSource.salary(name: "Palkka", rule: .lastBankingDayOfMonth)

        #expect(source.title == "Palkka")
    }

    @Test func aNamelessSalaryIsNotShownAsABlank() {
        let source = PaymentSource.salary(name: "   ", rule: .lastBankingDayOfMonth)

        #expect(!source.title.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    @Test func aBenefitIsNamedByTheCatalog() {
        let benefit = BenefitCatalog.bundled.benefits[0]
        let source = PaymentSource.benefit(benefit)

        #expect(source.title == benefit.name.value())
    }
}
