import SwiftUI

/// The settings tab: how the home screen looks, and information about the app.
struct SettingsView: View {
    @AppStorage(SharedDefaults.progressStyleKey, store: SharedDefaults.shared)
    private var progressStyle: ProgressStyle = .ring

    // `URL(string:)` IDNA-encodes the host, so the Unicode domain ("tilipäivä")
    // is fine here; the punycode form is xn--tilipiv-9wac.ruupert.fi.
    private let supportURL = URL(string: "https://tilipäivä.ruupert.fi/")!
    private let privacyPolicyURL = URL(string: "https://tilipäivä.ruupert.fi/privacy.html")!

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle("Progress ring", isOn: showsRing)
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

    /// The ring is either drawn or not, so the stored style is driven by a switch.
    private var showsRing: Binding<Bool> {
        Binding(
            get: { progressStyle == .ring },
            set: { progressStyle = $0 ? .ring : .none }
        )
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
