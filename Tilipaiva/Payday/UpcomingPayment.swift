import Foundation

/// A payment source paired with one of its resolved dates, ready for display.
nonisolated struct UpcomingPayment: Identifiable, Hashable, Sendable {
    let source: PaymentSource
    let occurrence: PaymentOccurrence

    var id: PaymentOccurrence.ID { occurrence.id }
    var date: Date { occurrence.date }

    /// The source's localized display name.
    var title: String { source.title }

    /// The number of whole days from one day to the payment date.
    func daysUntil(from date: Date = .now, calendar: BankingCalendar = BankingCalendar()) -> Int {
        calendar.dayCount(from: date, to: self.date)
    }
}

extension UpcomingPayment: Comparable {
    /// Ordered by date, then by source so the order is stable.
    static func < (lhs: UpcomingPayment, rhs: UpcomingPayment) -> Bool {
        (lhs.date, lhs.source.id.uuidString) < (rhs.date, rhs.source.id.uuidString)
    }
}
