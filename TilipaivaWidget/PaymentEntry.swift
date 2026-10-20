import WidgetKit

struct PaymentEntry: TimelineEntry {
    let date: Date
    let payment: UpcomingPayment?

    /// The wait the next payment ends, when the source has an earlier payment to
    /// measure it from. The circular Lock Screen widget fills its ring from it.
    let cycle: PaymentCycle?
}
