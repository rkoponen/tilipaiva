import Foundation
import Testing
@testable import Tilipaiva

/// Acceptance tests that recompute the 2026 Kela payment days and compare them
/// against the published dates on kela.fi/maksupaivat.
struct BenefitCatalogTests {
    private let resolver = PaymentResolver()

    private var helsinki: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = BankingCalendar.timeZone
        return calendar
    }

    private func benefit(_ id: String) -> Benefit {
        BenefitCatalog.bundled.benefit(id: Benefit.ID(rawValue: id))!
    }

    /// The day of each month in 2026 on which the benefit is paid.
    private func paymentDays(for id: String) -> [Int] {
        let source = PaymentSource.benefit(benefit(id))
        return (1...12).map { month in
            let date = resolver.date(for: source, in: Month(year: 2026, month: month))!
            return helsinki.component(.day, from: date)
        }
    }

    @Test func bundledCatalogContainsTheTierOneBenefits() {
        let ids = BenefitCatalog.bundled.benefits.map(\.id.rawValue).sorted()
        #expect(ids == [
            "elatustuki",
            "hoitoraha",
            "kansanelake",
            "kotihoidontuki",
            "kuntoutustuki",
            "lapsilisa",
            "opintotuki",
        ])
    }

    @Test func benefitNamesAreLocalized() {
        let lapsilisa = benefit("lapsilisa")
        #expect(lapsilisa.name.value(for: Locale(identifier: "fi_FI")) == "Lapsilisä")
        #expect(lapsilisa.name.value(for: Locale(identifier: "en_US")) == "Child benefit")
    }

    // kela.fi: kansaneläke and kuntoutustuki/työkyvyttömyyseläke are both paid on
    // the 7th, or the previous banking day when the banks are closed.
    @Test func pensionsAndDisabilityBenefitsPayOnTheSeventh() {
        let expected = [7, 6, 6, 7, 7, 5, 7, 7, 7, 7, 6, 7]
        #expect(paymentDays(for: "kansanelake") == expected)
        #expect(paymentDays(for: "kuntoutustuki") == expected)
    }

    // kela.fi: elatustuki is paid on the 10th, or the previous banking day.
    @Test func childMaintenanceAllowancePaysOnTheTenth() {
        #expect(paymentDays(for: "elatustuki") == [9, 10, 10, 10, 8, 10, 10, 10, 10, 9, 10, 10])
    }

    // kela.fi: lapsilisä is paid on the 26th, but shifts to the previous banking
    // day when the 26th is a Saturday, Sunday, Monday or a holiday.
    @Test func childBenefitPaysOnTheTwentySixth() {
        #expect(paymentDays(for: "lapsilisa") == [23, 26, 26, 24, 26, 26, 24, 26, 25, 23, 26, 23])
    }

    // kela.fi: opintoraha and asumislisä are paid on the 1st, or the next banking
    // day when the banks are closed.
    @Test func studyGrantPaysOnTheFirst() {
        #expect(paymentDays(for: "opintotuki") == [2, 2, 2, 1, 4, 1, 1, 3, 1, 1, 2, 1])
    }

    // kela.fi: child home care allowance is paid on the last weekday of the month.
    @Test func childHomeCareAllowancePaysOnTheLastWeekday() {
        #expect(paymentDays(for: "kotihoidontuki") == [30, 27, 31, 30, 29, 30, 31, 31, 30, 30, 30, 31])
    }

    // kela.fi: flexible and partial care allowance is paid on the last banking day.
    @Test func careAllowancePaysOnTheLastBankingDay() {
        #expect(paymentDays(for: "hoitoraha") == [30, 27, 31, 30, 29, 30, 31, 31, 30, 30, 30, 31])
    }
}
