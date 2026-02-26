import Foundation

struct RoomEstimate: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var roomType: RoomType
    var length: Double
    var width: Double
    var height: Double
    var items: [EstimateItem]
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()
    var notes: String = ""

    var areaSqM: Double    { length * width }
    var wallAreaSqM: Double { 2 * (length + width) * height }
    var totalCost: Double  { items.reduce(0) { $0 + $1.totalCost } }
}
