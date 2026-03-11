import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var email       = ""
    @State private var password    = ""
    @State private var showPass    = false
    @State private var showReset   = false
    @FocusState private var focus: Field?

    enum Field { case email, password }

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle().fill(Color.seNavy.opacity(0.08)).frame(width: 72, height: 72)
                                Image(systemName: "person.fill.checkmark")
                                    .font(.system(size: 30)).foregroundColor(.seNavy)
                            }
                            Text("Welcome Back")
                                .font(SEFont.title2()).foregroundColor(.seText)
                            Text("Sign in to your account")
                                .font(SEFont.subheadline()).foregroundColor(.seSubtext)
                        }
                        .padding(.top, 8)

                        // Error
                        if let err = authVM.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.seError)
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
                            AuthField(label: "Email", placeholder: "you@example.com",
                                      text: $email, icon: "envelope.fill",
                                      keyboard: .emailAddress, focused: focus == .email)
                            .focused($focus, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focus = .password }

                            AuthField(label: "Password", placeholder: "Your password",
                                      text: $password, icon: "lock.fill",
                                      isSecure: !showPass, focused: focus == .password,
                                      trailingIcon: showPass ? "eye.slash.fill" : "eye.fill",
                                      trailingAction: { showPass.toggle() })
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .onSubmit { attemptSignIn() }
                        }
                        .seCard()

                        // Forgot password
                        Button { showReset = true } label: {
                            Text("Forgot password?")
                                .font(SEFont.subheadline())
                                .foregroundColor(.seAmber)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                        // Submit
                        Button { attemptSignIn() } label: {
                            ZStack {
                                if authVM.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Label("Sign In", systemImage: "arrow.right.circle.fill")
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

                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?").foregroundColor(.seSubtext)
                                Text("Sign Up").foregroundColor(.seAmber).fontWeight(.semibold)
                            }
                            .font(SEFont.subheadline())
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
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
            .sheet(isPresented: $showReset) {
                ForgotPasswordView().environmentObject(authVM)
            }
            .onChange(of: authVM.authState) { state in
                if state == .authenticated { presentationMode.wrappedValue.dismiss() }
            }
        }
    }

    private var isFormValid: Bool { email.contains("@") && !password.isEmpty }

    private func attemptSignIn() {
        authVM.clearError()
        focus = nil
        authVM.signIn(email: email, password: password)
    }
}

// MARK: - Forgot Password Sheet
struct ForgotPasswordView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var sent  = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.seAmber.opacity(0.10)).frame(width: 72, height: 72)
                            Image(systemName: "key.fill")
                                .font(.system(size: 30)).foregroundColor(.seAmber)
                        }
                        Text("Reset Password").font(SEFont.title2())
                        Text("We'll send a reset link to your email.")
                            .font(SEFont.subheadline()).foregroundColor(.seSubtext)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    if sent {
                        VStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40)).foregroundColor(.seSuccess)
                            Text("Reset email sent!")
                                .font(SEFont.headline()).foregroundColor(.seSuccess)
                            Text("Check your inbox and follow the instructions.")
                                .font(SEFont.caption()).foregroundColor(.seSubtext)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .seCard()
                    } else {
                        VStack(spacing: 14) {
                            AuthField(label: "Email", placeholder: "you@example.com",
                                      text: $email, icon: "envelope.fill",
                                      keyboard: .emailAddress, focused: false)
                        }
                        .seCard()

                        if let err = authVM.errorMessage {
                            Text(err).font(SEFont.caption()).foregroundColor(.seError)
                                .padding(10).background(Color.seError.opacity(0.08)).cornerRadius(8)
                        }

                        Button {
                            authVM.resetPassword(email: email) { success in
                                if success { withAnimation { sent = true } }
                            }
                        } label: {
                            ZStack {
                                if authVM.isLoading { ProgressView().tint(.white) }
                                else { Text("Send Reset Link").font(SEFont.headline()).foregroundColor(.white) }
                            }
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(email.contains("@") ?
                                LinearGradient.seAmberGradient :
                                LinearGradient(colors: [Color.seSubtext.opacity(0.4), Color.seSubtext.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .disabled(!email.contains("@") || authVM.isLoading)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "xmark").foregroundColor(.seNavy)
                    }
                }
            }
        }
    }
}
