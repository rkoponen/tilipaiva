import Foundation
import Testing
@testable import Tilipaiva

struct PaymentCycleTests {
    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = BankingCalendar.timeZone
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func fractionRunsFromZeroToFull() {
        let cycle = PaymentCycle(previous: day(2026, 1, 1), next: day(2026, 1, 31))
        #expect(cycle.fraction(on: day(2026, 1, 1)) == 0)
        #expect(cycle.fraction(on: day(2026, 1, 16)) == 0.5)
        #expect(cycle.fraction(on: day(2026, 1, 31)) == 1)
    }

    @Test func fractionIsClampedOutsideTheCycle() {
        let cycle = PaymentCycle(previous: day(2026, 1, 1), next: day(2026, 1, 31))
        #expect(cycle.fraction(on: day(2025, 12, 20)) == 0)
        #expect(cycle.fraction(on: day(2026, 2, 20)) == 1)
    }

    @Test func aCycleWithoutLengthCountsAsFull() {
        let cycle = PaymentCycle(previous: day(2026, 1, 1), next: day(2026, 1, 1))
        #expect(cycle.fraction(on: day(2026, 1, 1)) == 1)
    }
}
