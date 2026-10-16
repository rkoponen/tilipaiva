import SwiftUI

/// The settings tab: the app's preferences and information about it.
struct SettingsView: View {
    /// Whether the payday confetti and its tap are wanted. The key is shared
    /// with `PaydayCelebration`, which reads the same store, and an absent value
    /// means on.
    @AppStorage(PaydayCelebration.enabledKey, store: SharedDefaults.defaults(suiteName: SharedDefaults.appGroupID))
    private var celebratesPaydays = true

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
    SettingsView()
}
