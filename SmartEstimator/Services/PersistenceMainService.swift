import Foundation
import Combine

class PersistenceMainService: ObservableObject {
    static let shared = PersistenceMainService()

    @Published var estimates: [RoomEstimate] = []
    @Published var customMaterials: [Material] = []

    private let estimatesKey     = "saved_estimates"
    private let customMatsKey    = "custom_materials"

    init() {
        loadEstimates()
        loadCustomMaterials()
    }

    // MARK: - Estimates
    func loadEstimates() {
        guard let data = UserDefaults.standard.data(forKey: estimatesKey),
              let decoded = try? JSONDecoder().decode([RoomEstimate].self, from: data) else { return }
        estimates = decoded
    }

    func save(estimate: RoomEstimate) {
        if let idx = estimates.firstIndex(where: { $0.id == estimate.id }) {
            estimates[idx] = estimate
        } else {
            estimates.insert(estimate, at: 0)
        }
        persistEstimates()
    }

    func delete(estimate: RoomEstimate) {
        estimates.removeAll { $0.id == estimate.id }
        persistEstimates()
    }

    func duplicate(estimate: RoomEstimate) {
        var copy = estimate
        copy.id = UUID()
        copy.name = estimate.name + " (Copy)"
        copy.createdAt = Date()
        copy.modifiedAt = Date()
        estimates.insert(copy, at: 0)
        persistEstimates()
    }

    private func persistEstimates() {
        if let encoded = try? JSONEncoder().encode(estimates) {
            UserDefaults.standard.set(encoded, forKey: estimatesKey)
        }
    }

    // MARK: - Custom Materials
    func loadCustomMaterials() {
        guard let data = UserDefaults.standard.data(forKey: customMatsKey),
              let decoded = try? JSONDecoder().decode([Material].self, from: data) else { return }
        customMaterials = decoded
    }

    func save(material: Material) {
        if let idx = customMaterials.firstIndex(where: { $0.id == material.id }) {
            customMaterials[idx] = material
        } else {
            customMaterials.append(material)
        }
        persistCustomMaterials()
    }

    func delete(material: Material) {
        customMaterials.removeAll { $0.id == material.id }
        persistCustomMaterials()
    }

    private func persistCustomMaterials() {
        if let encoded = try? JSONEncoder().encode(customMaterials) {
            UserDefaults.standard.set(encoded, forKey: customMatsKey)
        }
    }

    func allMaterials() -> [Material] {
        DefaultMaterials.catalog + customMaterials
    }
}
