import SwiftUI

/// Reusable styled text field for auth screens
struct AuthField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var focused: Bool = false
    var trailingIcon: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(SEFont.caption())
                .foregroundColor(.seSubtext)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(focused ? .seAmber : .seSubtext)
                    .frame(width: 20)

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboard)
                            .autocapitalization(keyboard == .emailAddress ? .none : .words)
                            .disableAutocorrection(keyboard == .emailAddress || isSecure)
                    }
                }
                .font(SEFont.body())
                .foregroundColor(.seText)

                if let icon = trailingIcon, let action = trailingAction {
                    Button(action: action) {
                        Image(systemName: icon)
                            .font(.system(size: 15))
                            .foregroundColor(.seSubtext)
                    }
                }
            }
            .padding(12)
            .background(Color.seSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focused ? Color.seAmber : Color.seNavy.opacity(0.12), lineWidth: focused ? 1.5 : 1)
            )
            .animation(.easeInOut(duration: 0.2), value: focused)
        }
    }
}

/// Floating error banner shown at top of screen
struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.seError)
                .font(.system(size: 18))
            Text(message)
                .font(SEFont.caption())
                .foregroundColor(.seText)
                .lineLimit(2)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.seSubtext)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.seError.opacity(0.2), radius: 12, y: 4)
        .padding(.horizontal, 20)
    }
}
