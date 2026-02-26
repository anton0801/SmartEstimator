import Foundation

struct EstimateItem: Identifiable, Codable {
    var id: UUID = UUID()
    var material: Material
    var areaSqM: Double
    var wastePercentage: Double

    var netQuantity: Double { areaSqM / material.coveragePerUnit }
    var grossQuantity: Double { netQuantity * (1 + wastePercentage / 100) }
    var unitsNeeded: Int { Int(ceil(grossQuantity)) }
    var totalCost: Double { Double(unitsNeeded) * material.pricePerUnit }
}
