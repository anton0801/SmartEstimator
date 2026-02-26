import SwiftUI

@main
struct SmartEstimatorApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            } else {
                if appState.hasCompletedOnboarding {
                    MainTabView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .opacity
                        ))
                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showSplash)
        .animation(.easeInOut(duration: 0.6), value: appState.hasCompletedOnboarding)
    }
}
