import Foundation

/// A single resolved payment date for a source.
nonisolated struct PaymentOccurrence: Identifiable, Hashable, Sendable {
    nonisolated struct ID: Hashable, Sendable {
        let sourceID: UUID
        let date: Date
    }

    let sourceID: UUID
    let date: Date

    var id: ID { ID(sourceID: sourceID, date: date) }
}

extension PaymentOccurrence: Comparable {
    /// Occurrences are ordered by date, then by source so the order is stable.
    static func < (lhs: PaymentOccurrence, rhs: PaymentOccurrence) -> Bool {
        (lhs.date, lhs.sourceID.uuidString) < (rhs.date, rhs.sourceID.uuidString)
    }
}
