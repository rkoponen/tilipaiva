import Foundation
import Testing
@testable import Tilipaiva

@MainActor
struct PaymentSourcesModelTests {
    private let suite = "fi.ruupert.TilipaivaTests.model"

    private func makeModel() -> PaymentSourcesModel {
        UserDefaults.standard.removePersistentDomain(forName: suite)
        return PaymentSourcesModel(store: PaymentSourceStore(suiteName: suite))
    }

    @Test func aNewModelHasNoUpcomingPayments() {
        let model = makeModel()
        #expect(model.sources.isEmpty)
        #expect(model.next == nil)
        #expect(!model.hasBenefitSources)
    }

    @Test func addingASourceResolvesTheNextPayment() {
        let model = makeModel()
        let salary = PaymentSource.salary(name: "Palkka", rule: .fixedDayOfMonth(day: 15, shift: .none, alsoShiftOnWeekdays: []))
        model.upsert(salary)

        #expect(model.sources == [salary])
        #expect(model.next?.source == salary)
        #expect(model.next?.date != nil)
    }

    @Test func upsertReplacesAnExistingSource() {
        let model = makeModel()
        var salary = PaymentSource.salary(name: "Palkka", rule: .fixedDayOfMonth(day: 15, shift: .none, alsoShiftOnWeekdays: []))
        model.upsert(salary)

        salary.name = "Uusi palkka"
        model.upsert(salary)

        #expect(model.sources == [salary])
    }

    @Test func benefitSourcesAreReported() {
        let model = makeModel()
        let benefit = PaymentSource(kind: .benefit, rule: .firstBankingDayOfMonth, benefitID: Benefit.ID(rawValue: "kansanelake"))
        model.upsert(benefit)
        #expect(model.hasBenefitSources)
    }

    @Test func deletingASourceClearsIt() {
        let model = makeModel()
        let salary = PaymentSource.salary(name: "Palkka", rule: .fixedDayOfMonth(day: 15, shift: .none, alsoShiftOnWeekdays: []))
        model.upsert(salary)
        model.delete(salary)

        #expect(model.sources.isEmpty)
        #expect(model.next == nil)
    }
}
