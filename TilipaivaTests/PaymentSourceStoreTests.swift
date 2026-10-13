import Foundation
import Testing
@testable import Tilipaiva

struct PaymentSourceStoreTests {
    private let suite = "fi.ruupert.TilipaivaTests.store"

    private func makeStore() -> PaymentSourceStore {
        UserDefaults.standard.removePersistentDomain(forName: suite)
        return PaymentSourceStore(suiteName: suite)
    }

    @Test func sourcesRoundTripThroughTheStore() {
        let store = makeStore()
        let sources = [
            PaymentSource.salary(name: "Palkka", rule: .fixedDayOfMonth(day: 15, shift: .none, alsoShiftOnWeekdays: [])),
            PaymentSource(
                kind: .benefit,
                rule: .fixedDayOfMonth(day: 26, shift: .previousBankingDay, alsoShiftOnWeekdays: [.monday]),
                benefitID: Benefit.ID(rawValue: "lapsilisa")
            ),
        ]
        store.save(sources)
        #expect(store.load() == sources)
    }

    @Test func anEmptyStoreLoadsNothing() {
        #expect(makeStore().load().isEmpty)
    }
}
