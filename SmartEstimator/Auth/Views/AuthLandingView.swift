import SwiftUI

struct AuthLandingView: View {
    @State private var showSignIn  = false
    @State private var showSignUp  = false
    @State private var bgRotation: Double = 0
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            // Background
            LinearGradient.seNavyGradient.ignoresSafeArea()
            BlueprintGridView().opacity(0.09)

            // Rotating decorative circle
            Circle()
                .stroke(Color.seAmber.opacity(0.12), lineWidth: 1)
                .frame(width: 420, height: 420)
                .rotationEffect(.degrees(bgRotation))
                .onAppear {
                    withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                        bgRotation = 360
                    }
                }
            Circle()
                .stroke(Color.seAmber.opacity(0.07), lineWidth: 1)
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(-bgRotation))

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 18) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(LinearGradient.seAmberGradient)
                            .frame(width: 96, height: 96)
                            .shadow(color: Color.seAmber.opacity(0.45), radius: 20, y: 8)
                        Image(systemName: "house.fill")
                            .font(.system(size: 44)).foregroundColor(.white)
                        Image(systemName: "pencil.and.ruler.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.85))
                            .offset(x: 18, y: 18)
                    }

                    VStack(spacing: 6) {
                        Text("Smart Estimator")
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .foregroundColor(.white)
                        Text("Calculate materials in seconds")
                            .font(SEFont.subheadline())
                            .foregroundColor(.white.opacity(0.65))
                    }
                }

                Spacer()

                // Tagline
                VStack(spacing: 4) {
                    HStack(spacing: 16) {
                        FeaturePill(icon: "camera.viewfinder", text: "Photo measure")
                        FeaturePill(icon: "doc.richtext",      text: "PDF export")
                    }
                    HStack(spacing: 16) {
                        FeaturePill(icon: "shippingbox.fill",  text: "50+ materials")
                        FeaturePill(icon: "icloud.fill",       text: "Cloud sync")
                    }
                }
                .padding(.bottom, 36)

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        withAnimation { showSignUp = true }
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Create Free Account")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient.seAmberGradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.seAmber.opacity(0.45), radius: 12, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button {
                        withAnimation { showSignIn = true }
                    } label: {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.12))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2)))
                    }
                    .buttonStyle(ScaleButtonStyle())

                    // Guest separator
                    HStack {
                        Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
                        Text("or").font(SEFont.caption()).foregroundColor(.white.opacity(0.45)).padding(.horizontal, 10)
                        Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
                    }
                    .padding(.vertical, 4)

                    Button {
                        authVM.continueAsGuest()
                    } label: {
                        HStack {
                            Image(systemName: "person.fill.questionmark")
                            Text("Continue as Guest")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white.opacity(0.65))
                        .font(SEFont.subheadline())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .overlay(alignment: .bottom) {
                        Text("No sync • data stays on device only")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.white.opacity(0.35))
                            .offset(y: 18)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 60)
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authVM)
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
                .environmentObject(authVM)
        }
        .overlay(alignment: .top) {
            if let err = authVM.errorMessage {
                ErrorBanner(message: err) { authVM.clearError() }
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4), value: authVM.errorMessage)
            }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 12))
            Text(text).font(.system(size: 12, weight: .medium, design: .rounded))
        }
        .foregroundColor(.white.opacity(0.75))
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Color.white.opacity(0.08))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12)))
    }
}
