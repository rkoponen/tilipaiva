import SwiftUI

/// The main screen: the next payday, followed by the upcoming payments.
struct HomeView: View {
    let model: PaymentSourcesModel
    var onSelect: (PaymentSource) -> Void

    @AppStorage(SharedDefaults.progressStyleKey, store: SharedDefaults.shared)
    private var progressStyle: ProgressStyle = .ring

    var body: some View {
        if let next = model.next {
            ScrollView {
                VStack(spacing: Design.sectionSpacing) {
                    // Give the countdown most of the first screen so the list
                    // sits below it rather than competing with it.
                    PaydayCountdownView(payment: next, cycle: model.nextCycle, progressStyle: progressStyle)
                        .containerRelativeFrame(.vertical, alignment: .center) { length, _ in length * 0.55 }

                    if !model.upcoming.isEmpty {
                        UpcomingPaymentsSection(payments: model.upcoming, onSelect: onSelect)
                    }

                    if model.hasBenefitSources {
                        PaymentDisclaimer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        } else {
            // An empty screen has nothing to scroll, so the empty state takes the
            // whole area and centres itself in it instead of hanging off the top.
            ScrollView {
                HomeEmptyStateView()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .containerRelativeFrame(.vertical, alignment: .center)
            }
        }
    }
}
