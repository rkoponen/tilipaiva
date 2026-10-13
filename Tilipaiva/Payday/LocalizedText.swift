import Foundation

/// A string with Finnish and English variants, used for benefit names that ship
/// in `Benefits.json` rather than in the string catalog.
nonisolated struct LocalizedText: Hashable, Codable, Sendable {
    let fi: String
    let en: String

    /// The variant matching the language of the locale, falling back to English.
    func value(for locale: Locale = .current) -> String {
        locale.language.languageCode?.identifier == "fi" ? fi : en
    }
}
