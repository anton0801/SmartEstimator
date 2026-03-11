import SwiftUI
import Firebase

@main
struct SmartEstimatorApp: App {
    @StateObject private var appState   = ApplicationState()
    @StateObject private var authVM     = AuthViewModel()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var selfDelegate

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}

struct RootView: View {
    @StateObject private var appState   = ApplicationState()
    @StateObject private var authVM     = AuthViewModel()

    var body: some View {
        ZStack {
            switch authVM.authState {
            case .loading:
                LoadingView()
                    .transition(.opacity)
            case .unauthenticated:
                if appState.hasCompletedOnboarding {
                    AuthLandingView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity))
                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            case .authenticated, .guest:
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .opacity))
            }
        }
        .preferredColorScheme(.light)
        .animation(.easeInOut(duration: 0.45), value: authVM.authState)
        .environmentObject(appState)
        .environmentObject(authVM)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            LinearGradient.seNavyGradient.ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient.seAmberGradient)
                        .frame(width: 72, height: 72)
                    Image(systemName: "house.fill")
                        .font(.system(size: 32)).foregroundColor(.white)
                }
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.seAmber)
            }
        }
    }
}
