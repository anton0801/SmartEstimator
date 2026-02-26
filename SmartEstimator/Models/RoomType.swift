import SwiftUI

enum RoomType: String, CaseIterable, Codable {
    case kitchen    = "Kitchen"
    case bathroom   = "Bathroom"
    case livingRoom = "Living Room"
    case bedroom    = "Bedroom"
    case hallway    = "Hallway"
    case balcony    = "Balcony"
    case custom     = "Custom"

    var icon: String {
        switch self {
        case .kitchen:    return "fork.knife"
        case .bathroom:   return "drop.fill"
        case .livingRoom: return "sofa.fill"
        case .bedroom:    return "bed.double.fill"
        case .hallway:    return "door.left.hand.open"
        case .balcony:    return "sun.horizon.fill"
        case .custom:     return "square.dashed"
        }
    }

    var color: Color {
        switch self {
        case .kitchen:    return Color(hex: "#FF8C42")
        case .bathroom:   return Color(hex: "#5B7FFF")
        case .livingRoom: return Color(hex: "#34C77B")
        case .bedroom:    return Color(hex: "#A259FF")
        case .hallway:    return Color(hex: "#F5A623")
        case .balcony:    return Color(hex: "#00C2CB")
        case .custom:     return Color(hex: "#7B8AB4")
        }
    }
}
