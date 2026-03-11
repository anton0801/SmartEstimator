import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemIcon: String
    let accentColor: Color
    let bgIcon: String
}

struct OnboardingView: View {
    @EnvironmentObject var appState: ApplicationState
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Measure Any Room",
            subtitle: "Snap a photo, tap 4 corners, and get the area instantly. No AR needed.",
            systemIcon: "camera.viewfinder",
            accentColor: .seAmber,
            bgIcon: "house.fill"
        ),
        OnboardingPage(
            title: "Pick Your Materials",
            subtitle: "Browse 50+ built-in materials with editable prices. Add your own custom items.",
            systemIcon: "list.bullet.rectangle.fill",
            accentColor: Color(hex: "#34C77B"),
            bgIcon: "shippingbox.fill"
        ),
        OnboardingPage(
            title: "Get Instant Estimates",
            subtitle: "Auto-calculate quantities with 10–15% waste buffer. See cost per item and totals.",
            systemIcon: "chart.bar.fill",
            accentColor: Color(hex: "#5B7FFF"),
            bgIcon: "dollarsign.circle.fill"
        ),
        OnboardingPage(
            title: "Export & Save",
            subtitle: "Save estimates and export professional PDF reports in one tap.",
            systemIcon: "square.and.arrow.up.fill",
            accentColor: Color(hex: "#FF6B6B"),
            bgIcon: "doc.fill"
        )
    ]

    var body: some View {
        ZStack {
            pages[currentPage].accentColor.opacity(0.12)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: currentPage)

            LinearGradient(
                colors: [Color.seNavy.opacity(0.04), Color.clear],
                startPoint: .bottom, endPoint: .top
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation { appState.hasCompletedOnboarding = true }
                    }
                    .font(SEFont.subheadline())
                    .foregroundColor(.seSubtext)
                    .padding()
                }

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                        OnboardingPageView(page: page, isActive: currentPage == idx)
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? Color.seAmber : Color.seSubtext.opacity(0.3))
                                .frame(width: i == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation { appState.hasCompletedOnboarding = true }
                        }
                    } label: {
                        HStack {
                            Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SEPrimaryButtonStyle())
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    @State private var bgIconRotation: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Image(systemName: page.bgIcon)
                    .font(.system(size: 180))
                    .foregroundColor(page.accentColor.opacity(0.08))
                    .rotationEffect(.degrees(bgIconRotation))
                    .onAppear {
                        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                            bgIconRotation = 360
                        }
                    }

                ZStack {
                    Circle().fill(page.accentColor.opacity(0.15)).frame(width: 160, height: 160)
                    Circle().fill(page.accentColor.opacity(0.25)).frame(width: 120, height: 120)
                    Image(systemName: page.systemIcon)
                        .font(.system(size: 56))
                        .foregroundColor(page.accentColor)
                }
                .scaleEffect(isActive ? 1 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1), value: isActive)
            }
            .frame(height: 240)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(SEFont.title())
                    .foregroundColor(.seText)
                    .multilineTextAlignment(.center)
                    .opacity(isActive ? 1 : 0)
                    .offset(y: isActive ? 0 : 16)
                    .animation(.easeOut(duration: 0.4).delay(0.15), value: isActive)

                Text(page.subtitle)
                    .font(SEFont.body())
                    .foregroundColor(.seSubtext)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(isActive ? 1 : 0)
                    .offset(y: isActive ? 0 : 16)
                    .animation(.easeOut(duration: 0.4).delay(0.25), value: isActive)
            }

            Spacer()
        }
    }
}
