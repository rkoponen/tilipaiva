import Foundation
import Testing
@testable import Tilipaiva

struct PaydayCelebrationTests {
    private let suite = "fi.ruupert.TilipaivaTests.celebration"

    private func makeCelebration() -> PaydayCelebration {
        UserDefaults.standard.removePersistentDomain(forName: suite)
        return PaydayCelebration(suiteName: suite)
    }

    /// A moment on a Finnish day; the hour only matters where the test gives it.
    private func moment(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = BankingCalendar.timeZone
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    /// A moment given in UTC, for the test that has to leave the Finnish day.
    private func instant(_ iso: String) -> Date {
        ISO8601DateFormatter().date(from: iso)!
    }

    @Test func theCelebrationIsOnUntilItIsTurnedOff() {
        let celebration = makeCelebration()
        #expect(celebration.isEnabled)

        SharedDefaults.defaults(suiteName: suite).set(false, forKey: PaydayCelebration.enabledKey)
        #expect(!celebration.isEnabled)
    }

    @Test func theFirstOpenOfAPaydayPlays() {
        #expect(makeCelebration().shouldPlay(on: moment(2026, 10, 16, 7)))
    }

    @Test func theRestOfTheDayStaysQuiet() {
        let celebration = makeCelebration()
        celebration.markPlayed(on: moment(2026, 10, 16, 8))

        #expect(!celebration.shouldPlay(on: moment(2026, 10, 16, 8)))
        #expect(!celebration.shouldPlay(on: moment(2026, 10, 16, 13)))
        #expect(!celebration.shouldPlay(on: moment(2026, 10, 16, 23)))
    }

    @Test func theNextPaydayPlaysAgain() {
        let celebration = makeCelebration()
        celebration.markPlayed(on: moment(2026, 10, 16))

        #expect(celebration.shouldPlay(on: moment(2026, 11, 16)))
    }

    @Test func aTurnedOffCelebrationNeverPlays() {
        let celebration = makeCelebration()
        SharedDefaults.defaults(suiteName: suite).set(false, forKey: PaydayCelebration.enabledKey)
        celebration.markPlayed(on: moment(2026, 10, 15))

        #expect(!celebration.shouldPlay(on: moment(2026, 10, 16)))
    }

    @Test func theDayIsTheFinnishOne() {
        let celebration = makeCelebration()
        // 22:00 UTC on the 15th is already the 16th in Helsinki. The celebration
        // follows the Finnish payday, not the day the device happens to be in,
        // so it stays quiet through the Finnish 16th and plays again on the 17th.
        celebration.markPlayed(on: instant("2026-10-15T22:00:00Z"))

        #expect(!celebration.shouldPlay(on: moment(2026, 10, 16, 12)))
        #expect(celebration.shouldPlay(on: moment(2026, 10, 17, 12)))
    }
}
