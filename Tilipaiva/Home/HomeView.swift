import SwiftUI

/// The main screen: the next payday, followed by the upcoming payments.
struct HomeView: View {
    let model: PaymentSourcesModel
    var onSelect: (PaymentSource) -> Void
    var onAbout: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Design.sectionSpacing) {
                if model.next != nil {
                    // Give the countdown most of the first screen so the list
                    // sits below it rather than competing with it.
                    PaydayCountdownView(payment: model.next)
                        .containerRelativeFrame(.vertical, alignment: .center) { length, _ in length * 0.55 }
                } else {
                    PaydayCountdownView(payment: nil)
                }

                if !model.upcoming.isEmpty {
                    UpcomingPaymentsSection(payments: model.upcoming, onSelect: onSelect)
                }

                if model.hasBenefitSources {
                    PaymentDisclaimer()
                }

                Button("About", action: onAbout)
                    .font(.footnote)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}
