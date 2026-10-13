import WidgetKit

struct PaymentEntry: TimelineEntry {
    let date: Date
    let payment: UpcomingPayment?
}
