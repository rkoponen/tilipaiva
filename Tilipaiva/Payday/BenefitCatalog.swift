import Foundation
import os

/// The bundled set of supported Kela benefits.
nonisolated struct BenefitCatalog: Sendable {
    let benefits: [Benefit]

    init(benefits: [Benefit]) {
        self.benefits = benefits
    }

    /// The benefit with the given identifier, if it is in the catalog.
    func benefit(id: Benefit.ID) -> Benefit? {
        benefits.first { $0.id == id }
    }

    /// The benefits shipped with the app, loaded from `Benefits.json`.
    static let bundled = loadBundled()

    private static let logger = Logger(subsystem: "fi.ruupert.Tilipaiva", category: "BenefitCatalog")

    private static func loadBundled() -> BenefitCatalog {
        guard let url = Bundle.main.url(forResource: "Benefits", withExtension: "json") else {
            logger.error("Benefits.json is missing from the app bundle.")
            return BenefitCatalog(benefits: [])
        }
        do {
            let data = try Data(contentsOf: url)
            return BenefitCatalog(benefits: try JSONDecoder().decode([Benefit].self, from: data))
        } catch {
            logger.error("Failed to load Benefits.json: \(error.localizedDescription)")
            return BenefitCatalog(benefits: [])
        }
    }
}
