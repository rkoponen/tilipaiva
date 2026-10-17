import Foundation
import Testing
@testable import Tilipaiva

struct PaydayReminderPreferencesTests {
    private let suite = "fi.ruupert.TilipaivaTests.reminders"

    private func makePreferences() -> PaydayReminderPreferences {
        UserDefaults.standard.removePersistentDomain(forName: suite)
        return PaydayReminderPreferences(suiteName: suite)
    }

    @Test func theReminderIsOffUntilItIsTurnedOn() {
        let preferences = makePreferences()
        #expect(!preferences.isEnabled)
    }

    @Test func theChoiceIsRemembered() {
        let preferences = makePreferences()
        preferences.setEnabled(true)

        #expect(PaydayReminderPreferences(suiteName: suite).isEnabled)

        preferences.setEnabled(false)
        #expect(!PaydayReminderPreferences(suiteName: suite).isEnabled)
    }
}
