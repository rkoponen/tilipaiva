import SwiftUI

struct ContentView: View {
    @State private var model = PaymentSourcesModel()
    @State private var notifications = PaydayNotifications()
    @State private var editorItem: SourceEditorItem?

    /// Whether the payday confetti is on screen.
    @State private var isCelebrating = false

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView(model: model, onSelect: edit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        AddSourceButton(action: addSource)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    // The tab carries its own background: a TabView draws over
                    // one applied to the TabView itself.
                    .background { PaymentBackground().ignoresSafeArea() }
                    // The confetti belongs to the Home tab, so it covers the
                    // hero it celebrates.
                    .overlay {
                        if isCelebrating {
                            PaydayCelebrationView()
                                .ignoresSafeArea()
                                .transition(.opacity)
                        }
                    }
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsView(notifications: notifications)
            }
        }
        .sheet(item: $editorItem) { item in
            SourceEditorView(item: item, onSave: model.upsert, onDelete: model.delete)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.reload()
                celebrateIfPayday()
                rescheduleReminders()
            }
        }
        // A source that is added or removed changes the payment days the
        // reminders are for; the first one ever saved is also where the
        // permission is asked, since a reminder needs something to remind about.
        .onChange(of: model.sources) { _, _ in
            rescheduleReminders()
        }
        // `scenePhase` can already be `.active` on the first render, so a
        // foreground change is not enough to catch a launch on a payday.
        .task {
            celebrateIfPayday()
            await notifications.reschedule()
        }
    }

    /// Brings the scheduled reminders back in line with the sources and the day.
    private func rescheduleReminders() {
        Task {
            await notifications.reschedule()
        }
    }

    /// Plays the payday celebration when the app comes up on a payment day, at
    /// most once that day.
    ///
    /// The gate is asked twice — once for the state, once when recording it —
    /// because the launch and the first foreground change can arrive together,
    /// and the second one has to stay quiet.
    private func celebrateIfPayday() {
        guard let next = model.next, next.daysUntil() == 0 else { return }

        let celebration = PaydayCelebration()
        guard celebration.shouldPlay(on: .now) else { return }
        celebration.markPlayed(on: .now)

        withAnimation(.easeIn(duration: 0.25)) {
            isCelebrating = true
        }

        // The flourish is due a third of a second from now, so the haptic engine
        // is warmed here, while the confetti is still arriving: an engine started
        // from cold would miss its moment.
        PaydayHaptics.shared.prepare()

        Task {
            // The tap waits until the confetti is really on screen: feedback
            // asked for during the launch transition can be dropped by the
            // system, and the day is already marked as played, so a dropped tap
            // would not come round again.
            try? await Task.sleep(for: .milliseconds(350))
            PaydayHaptics.shared.play()

            // The longest fall plus its delay, and the fade below it, so the last
            // piece is gone before the view is taken away.
            try? await Task.sleep(for: .seconds(3.3))
            withAnimation(.easeOut(duration: 0.45)) {
                isCelebrating = false
            }
        }
    }

    private func addSource() {
        editorItem = .create
    }

    private func edit(_ source: PaymentSource) {
        editorItem = .edit(source)
    }
}

#Preview {
    ContentView()
}
