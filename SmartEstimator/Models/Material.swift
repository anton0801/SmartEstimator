import Foundation

enum MaterialCategory: String, CaseIterable, Codable {
    case paint     = "Paint"
    case wallpaper = "Wallpaper"
    case tiles     = "Tiles"
    case laminate  = "Laminate"
    case linoleum  = "Linoleum"
    case drywall   = "Drywall"
    case plaster   = "Plaster"
    case putty     = "Putty"
    case adhesive  = "Adhesive"
    case primer    = "Primer"
    case custom    = "Custom"

    var icon: String {
        switch self {
        case .paint:     return "paintbrush.fill"
        case .wallpaper: return "rectangle.pattern.checkered"
        case .tiles:     return "square.grid.2x2.fill"
        case .laminate:  return "rectangle.3.group.fill"
        case .linoleum:  return "rectangle.fill"
        case .drywall:   return "wall.and.floorplan"
        case .plaster:   return "circle.grid.cross.fill"
        case .putty:     return "paintbrush.pointed.fill"
        case .adhesive:  return "drop.triangle.fill"
        case .primer:    return "seal.fill"
        case .custom:    return "star.fill"
        }
    }
}

struct Material: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var category: MaterialCategory
    var unitLabel: String
    var coveragePerUnit: Double
    var pricePerUnit: Double
    var isCustom: Bool = false
    var brand: String = ""

    static func == (lhs: Material, rhs: Material) -> Bool { lhs.id == rhs.id }
}
