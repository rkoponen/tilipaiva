import SwiftUI
import UIKit

/// The settings tab: the app's preferences and information about it.
struct SettingsView: View {
    /// The reminder switch and its permission. Owned by `ContentView`, which
    /// reschedules from the same instance as the sources change.
    let notifications: PaydayNotifications

    /// Whether the payday confetti and its tap are wanted. The key is shared
    /// with `PaydayCelebration`, which reads the same store, and an absent value
    /// means on.
    @AppStorage(PaydayCelebration.enabledKey, store: SharedDefaults.defaults(suiteName: SharedDefaults.appGroupID))
    private var celebratesPaydays = true

    @Environment(\.openURL) private var openURL

    // `URL(string:)` IDNA-encodes the host, so the Unicode domain ("tilipäivä")
    // is fine here; the punycode form is xn--tilipiv-9wac.ruupert.fi.
    private let supportURL = URL(string: "https://tilipäivä.ruupert.fi/")!
    private let privacyPolicyURL = URL(string: "https://tilipäivä.ruupert.fi/privacy.html")!

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Celebrate a payday", isOn: $celebratesPaydays)
                } header: {
                    Text("Celebration")
                } footer: {
                    Text("Plays once when you first open the app on a payment day.")
                }

                Section {
                    if notifications.isDenied {
                        Button(action: openSystemSettings) {
                            Label("Turn on in Settings", systemImage: "bell.badge")
                        }
                    } else {
                        Toggle("Payment reminder", isOn: reminder)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("One reminder at 9 a.m. on a payment day.")
                }

                Section("About") {
                    LabeledContent("Version", value: version)

                    Link(destination: supportURL) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    Link(destination: privacyPolicyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
            }
            .navigationTitle(Text("Settings"))
        }
        .task {
            await notifications.refresh()
        }
    }

    /// The switch goes through `PaydayNotifications` rather than straight to the
    /// stored preference, because turning it on may have to ask the system for
    /// the permission first — and has to stay off if that ask is refused.
    private var reminder: Binding<Bool> {
        Binding(
            get: { notifications.isEnabled },
            set: { isEnabled in
                Task {
                    await notifications.setEnabled(isEnabled)
                }
            }
        )
    }

    /// Opens the app's page in the Settings app, the only place a refused
    /// notification permission can be given back.
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }

    /// The app's marketing version and build number, e.g. "1.0 (1)".
    private var version: String {
        let info = Bundle.main.infoDictionary
        let shortVersion = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(shortVersion) (\(build))"
    }
}

#Preview {
    SettingsView(notifications: PaydayNotifications())
}
