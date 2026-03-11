import SwiftUI

// MARK: - Colors
extension Color {
    static let seNavy      = Color(hex: "#1A2744")
    static let seNavyLight = Color(hex: "#2C3E6B")
    static let seAmber     = Color(hex: "#F5A623")
    static let seAmberDark = Color(hex: "#E8920F")
    static let seSurface   = Color(hex: "#F4F6FB")
    static let seCardBg    = Color.white
    static let seSuccess   = Color(hex: "#34C77B")
    static let seError     = Color(hex: "#FF4D4D")
    static let seText      = Color(hex: "#1A2744")
    static let seSubtext   = Color(hex: "#7B8AB4")

    init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        h = h.hasPrefix("#") ? String(h.dropFirst()) : h
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8)  & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension LinearGradient {
    static let seAmberGradient = LinearGradient(colors: [.seAmber, .seAmberDark], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let seNavyGradient  = LinearGradient(colors: [.seNavy, .seNavyLight],  startPoint: .topLeading, endPoint: .bottomTrailing)
}

struct SEFont {
    static func title()      -> Font { .system(.title,      design: .rounded).weight(.bold) }
    static func title2()      -> Font { .system(.title2,      design: .rounded).weight(.semibold) }
    static func headline()    -> Font { .system(.headline,    design: .rounded) }
    static func body()        -> Font { .system(.body,        design: .rounded) }
    static func subheadline() -> Font { .system(.subheadline, design: .rounded) }
    static func caption()     -> Font { .system(.caption,     design: .rounded) }
}

struct SECard: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content.padding(padding).background(Color.white).cornerRadius(16)
            .shadow(color: Color.seNavy.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}
extension View {
    func seCard(padding: CGFloat = 16) -> some View { modifier(SECard(padding: padding)) }
}

struct SEPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(SEFont.headline()).foregroundColor(.white)
            .padding(.vertical, 14).padding(.horizontal, 24)
            .background(LinearGradient.seAmberGradient).cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(color: Color.seAmber.opacity(0.4), radius: configuration.isPressed ? 4 : 10, y: 4)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
struct SESecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(SEFont.headline()).foregroundColor(.seNavy)
            .padding(.vertical, 14).padding(.horizontal, 24)
            .background(Color.seNavy.opacity(0.08)).cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct StaggerAppear: ViewModifier {
    let index: Int
    @State private var appeared = false
    func body(content: Content) -> some View {
        content.opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.07)) { appeared = true }
            }
    }
}
extension View {
    func staggerAppear(index: Int) -> some View { modifier(StaggerAppear(index: index)) }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat; var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                          cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}
