import SwiftUI

// MARK: - Text Field
struct AuthTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(SEFont.caption()).foregroundColor(.seSubtext)
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(text.isEmpty ? .seSubtext : .seAmber)
                    .frame(width: 20)
                    .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(SEFont.body())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.seSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(text.isEmpty ? Color.seNavy.opacity(0.12) : Color.seAmber.opacity(0.5), lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
        }
    }
}

// MARK: - Secure Field
struct AuthSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    @Binding var show: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(SEFont.caption()).foregroundColor(.seSubtext)
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(text.isEmpty ? .seSubtext : .seAmber)
                    .frame(width: 20)
                if show {
                    TextField(placeholder, text: $text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(SEFont.body())
                } else {
                    SecureField(placeholder, text: $text)
                        .font(SEFont.body())
                }
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { show.toggle() }
                } label: {
                    Image(systemName: show ? "eye.slash" : "eye")
                        .font(.system(size: 15))
                        .foregroundColor(.seSubtext)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.seSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(text.isEmpty ? Color.seNavy.opacity(0.12) : Color.seAmber.opacity(0.5), lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Banner
struct AuthBanner: View {
    let message: String
    let isError: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .seError : .seSuccess)
                .font(.system(size: 16))
            Text(message)
                .font(SEFont.caption())
                .foregroundColor(isError ? .seError : .seSuccess)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(12)
        .background((isError ? Color.seError : Color.seSuccess).opacity(0.08))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke((isError ? Color.seError : Color.seSuccess).opacity(0.2))
        )
    }
}

// MARK: - Password Strength Bar
struct PasswordStrengthBar: View {
    let password: String

    var strength: Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*")) != nil { score += 1 }
        return min(score, 4)
    }

    var label: String {
        switch strength {
        case 0, 1: return "Weak"
        case 2:    return "Fair"
        case 3:    return "Good"
        default:   return "Strong"
        }
    }

    var color: Color {
        switch strength {
        case 0, 1: return .seError
        case 2:    return .seAmber
        case 3:    return Color(hex: "#4CAF50")
        default:   return .seSuccess
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<4) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < strength ? color : Color.seNavy.opacity(0.1))
                        .frame(height: 4)
                        .animation(.spring(response: 0.3), value: strength)
                }
            }
            Text("Password strength: \(label)")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(color)
        }
    }
}

// MARK: - Outline Button Style (for landing)
struct SEOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SEFont.headline())
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(Color.clear)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.4), lineWidth: 1.5))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Ghost Button Style
struct SEGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SEFont.subheadline())
            .foregroundColor(.white.opacity(0.65))
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
