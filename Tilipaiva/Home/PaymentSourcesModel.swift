import Foundation
import Observation
import WidgetKit

/// Owns the user's payment sources and keeps the shared store and the widget in sync.
@Observable
final class PaymentSourcesModel {
    private let store: PaymentSourceStore
    private let resolver: PaymentResolver

    private(set) var sources: [PaymentSource]
    private(set) var upcoming: [UpcomingPayment]

    init(store: PaymentSourceStore = PaymentSourceStore(), resolver: PaymentResolver = PaymentResolver()) {
        self.store = store
        self.resolver = resolver
        let sources = store.load()
        self.sources = sources
        self.upcoming = resolver.upcoming(for: sources, onOrAfter: .now, limit: 8)
    }

    /// The next payment across every source, if there is one.
    var next: UpcomingPayment? { upcoming.first }

    /// The wait the next payment ends, used for the hero's progress.
    var nextCycle: PaymentCycle? {
        guard let next else { return nil }
        return resolver.cycle(endingAt: next)
    }

    /// Whether any tracked source is a Kela benefit, so the disclaimer is shown.
    var hasBenefitSources: Bool { sources.contains { $0.kind == .benefit } }

    /// Inserts or replaces a source, then persists the change.
    func upsert(_ source: PaymentSource) {
        if let index = sources.firstIndex(where: { $0.id == source.id }) {
            sources[index] = source
        } else {
            sources.append(source)
        }
        persist()
    }

    /// Removes a source, then persists the change.
    func delete(_ source: PaymentSource) {
        sources.removeAll { $0.id == source.id }
        persist()
    }

    /// Reloads from the store, e.g. when the app returns to the foreground.
    func reload() {
        sources = store.load()
        upcoming = resolver.upcoming(for: sources, onOrAfter: .now, limit: 8)
    }

    private func persist() {
        store.save(sources)
        upcoming = resolver.upcoming(for: sources, onOrAfter: .now, limit: 8)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
