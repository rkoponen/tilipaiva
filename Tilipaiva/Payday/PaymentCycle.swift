import Foundation

/// One full wait between two payments of the same source.
///
/// The wait is what a countdown is actually counting: it runs from the payment
/// before the next one to the next one, so its length follows the rule — a
/// fortnight for a biweekly salary, a month for a monthly one.
nonisolated struct PaymentCycle: Hashable, Sendable {
    /// The payment the wait started at.
    let previous: Date

    /// The payment the wait ends at.
    let next: Date

    /// How much of the wait has passed on the given day, from 0 when it starts
    /// to 1 on the day the payment arrives.
    ///
    /// Whole days are used, so the value does not creep during the day and stays
    /// in step with the "12 days" the countdown shows.
    func fraction(on date: Date = .now, calendar: BankingCalendar = BankingCalendar()) -> Double {
        let total = calendar.dayCount(from: previous, to: next)
        guard total > 0 else { return 1 }
        let elapsed = calendar.dayCount(from: previous, to: date)
        return min(1, max(0, Double(elapsed) / Double(total)))
    }
}
