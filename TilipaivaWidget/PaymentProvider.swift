import WidgetKit

struct PaymentProvider: TimelineProvider {
    private let store = PaymentSourceStore()
    private let resolver = PaymentResolver()
    private let calendar = BankingCalendar()

    func placeholder(in context: Context) -> PaymentEntry {
        PaymentEntry(date: .now, payment: nil, cycle: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (PaymentEntry) -> Void) {
        completion(entry(for: .now))
    }

    /// One entry per midnight for the next week, so the countdown rolls over on time.
    func getTimeline(in context: Context, completion: @escaping (Timeline<PaymentEntry>) -> Void) {
        let today = calendar.startOfDay(.now)
        let entries = (0...7).compactMap { offset -> PaymentEntry? in
            guard let day = Calendar.current.date(byAdding: .day, value: offset, to: today) else { return nil }
            return entry(for: day)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(for date: Date) -> PaymentEntry {
        let payment = resolver.next(for: store.load(), onOrAfter: date)
        return PaymentEntry(
            date: date,
            payment: payment,
            cycle: payment.flatMap { resolver.cycle(endingAt: $0) }
        )
    }
}
