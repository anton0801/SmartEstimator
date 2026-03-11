import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name        = ""
    @State private var email       = ""
    @State private var password    = ""
    @State private var confirmPass = ""
    @State private var showPass    = false
    @State private var showConfirm = false
    @State private var fieldError: String?
    @FocusState private var focus: Field?

    enum Field { case name, email, password, confirm }

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle().fill(Color.seAmber.opacity(0.12)).frame(width: 72, height: 72)
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 30)).foregroundColor(.seAmber)
                            }
                            Text("Create Account")
                                .font(SEFont.title2()).foregroundColor(.seText)
                            Text("Join Smart Estimator for free")
                                .font(SEFont.subheadline()).foregroundColor(.seSubtext)
                        }
                        .padding(.top, 8)

                        // Error
                        if let err = fieldError ?? authVM.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.seError)
                                Text(err).font(SEFont.caption()).foregroundColor(.seError)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.seError.opacity(0.08))
                            .cornerRadius(10)
                            .transition(.scale.combined(with: .opacity))
                        }

                        // Fields
                        VStack(spacing: 14) {
                            AuthField(label: "Full Name", placeholder: "Jane Smith",
                                      text: $name, icon: "person.fill",
                                      focused: focus == .name)
                            .focused($focus, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focus = .email }

                            AuthField(label: "Email", placeholder: "you@example.com",
                                      text: $email, icon: "envelope.fill",
                                      keyboard: .emailAddress, focused: focus == .email)
                            .focused($focus, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focus = .password }

                            AuthField(label: "Password", placeholder: "Min. 6 characters",
                                      text: $password, icon: "lock.fill",
                                      isSecure: !showPass, focused: focus == .password,
                                      trailingIcon: showPass ? "eye.slash.fill" : "eye.fill",
                                      trailingAction: { showPass.toggle() })
                            .focused($focus, equals: .password)
                            .submitLabel(.next)
                            .onSubmit { focus = .confirm }

                            AuthField(label: "Confirm Password", placeholder: "Repeat password",
                                      text: $confirmPass, icon: "lock.rotation",
                                      isSecure: !showConfirm, focused: focus == .confirm,
                                      trailingIcon: showConfirm ? "eye.slash.fill" : "eye.fill",
                                      trailingAction: { showConfirm.toggle() })
                            .focused($focus, equals: .confirm)
                            .submitLabel(.done)
                            .onSubmit { attemptSignUp() }
                        }
                        .seCard()

                        // Password strength
                        if !password.isEmpty {
                            PasswordStrengthView(password: password)
                                .transition(.opacity)
                        }

                        // Submit
                        Button { attemptSignUp() } label: {
                            ZStack {
                                if authVM.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Label("Create Account", systemImage: "checkmark.circle.fill")
                                        .font(SEFont.headline()).foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(isFormValid ?
                                LinearGradient.seAmberGradient :
                                LinearGradient(colors: [Color.seSubtext.opacity(0.4), Color.seSubtext.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                            .shadow(color: isFormValid ? Color.seAmber.opacity(0.35) : .clear, radius: 10, y: 4)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .disabled(!isFormValid || authVM.isLoading)

                        // Already have account
                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            HStack(spacing: 4) {
                                Text("Already have an account?").foregroundColor(.seSubtext)
                                Text("Sign In").foregroundColor(.seAmber).fontWeight(.semibold)
                            }
                            .font(SEFont.subheadline())
                        }

                        // Terms note
                        Text("By creating an account you agree to our Terms of Service and Privacy Policy.")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.seSubtext.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .animation(.spring(response: 0.3), value: fieldError)
                    .animation(.spring(response: 0.3), value: authVM.errorMessage)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.seNavy)
                    }
                }
            }
            .onChange(of: authVM.authState) { state in
                if state == .authenticated { presentationMode.wrappedValue.dismiss() }
            }
        }
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && password.count >= 6 && password == confirmPass
    }

    private func attemptSignUp() {
        fieldError = nil
        authVM.clearError()
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            fieldError = "Please enter your full name."; return
        }
        if password != confirmPass {
            fieldError = "Passwords do not match."; return
        }
        focus = nil
        authVM.signUp(email: email, password: password, name: name)
    }
}

struct PasswordStrengthView: View {
    let password: String

    private var strength: Int {
        var s = 0
        if password.count >= 8 { s += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { s += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { s += 1 }
        if password.rangeOfCharacter(from: CharacterSet.punctuationCharacters.union(.symbols)) != nil { s += 1 }
        return s
    }
    private var label: String  { ["Too short", "Weak", "Fair", "Good", "Strong"][min(strength, 4)] }
    private var color: Color   { [Color.seError, Color.seError, Color.seAmber, Color.seAmber, Color.seSuccess][min(strength, 4)] }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(i < strength ? color : Color.seNavy.opacity(0.12))
                        .frame(maxWidth: .infinity, minHeight: 4, maxHeight: 4)
                        .animation(.spring(response: 0.3), value: strength)
                }
            }
            Text("Password strength: \(label)")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 4)
    }
}
