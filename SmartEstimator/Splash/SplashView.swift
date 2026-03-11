import SwiftUI
import Combine

struct SplashView: View {

    @State private var gridOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var taglineOffset: CGFloat = 20
    @State private var taglineOpacity: Double = 0
    @State private var particles: [SplashParticle] = SplashParticle.generate(count: 30)
    @State private var particlesVisible = false
    
    @StateObject private var store = Store()
    @State private var streams = Set<AnyCancellable>()

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    LinearGradient.seNavyGradient
                        .ignoresSafeArea()
                    
                    BlueprintGridView()
                        .opacity(gridOpacity)
                    
                    Image("loading_background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .ignoresSafeArea()
                        .opacity(0.7)
                    
                    ForEach(particles) { p in
                        Circle()
                            .fill(Color.seAmber.opacity(p.opacity))
                            .frame(width: p.size, height: p.size)
                            .offset(x: p.x, y: p.y)
                            .scaleEffect(particlesVisible ? 1 : 0)
                            .animation(
                                .spring(response: 0.8, dampingFraction: 0.5)
                                .delay(p.delay),
                                value: particlesVisible
                            )
                    }
                    
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(LinearGradient.seAmberGradient)
                                .frame(width: 100, height: 100)
                            Image(systemName: "house.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                            Image(systemName: "pencil.and.ruler.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.9))
                                .offset(x: 20, y: 20)
                        }
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        
                        Text("Smart Estimator")
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .foregroundColor(.white)
                            .opacity(logoOpacity)
                        
                        Text("Calculate materials in seconds")
                            .font(SEFont.subheadline())
                            .foregroundColor(Color.white.opacity(0.7))
                            .offset(y: taglineOffset)
                            .opacity(taglineOpacity)
                        
                        ProgressView()
                            .tint(.white)
                    }
                    
                    NavigationLink(
                        destination: SmartWebView().navigationBarHidden(true),
                        isActive: $store.state.ui.navigateToWeb
                    ) { EmptyView() }
                    
                    NavigationLink(
                        destination: RootView().navigationBarBackButtonHidden(true),
                        isActive: $store.state.ui.navigateToMain
                    ) { EmptyView() }
                }
                .onAppear {
                    animate()
                    store.dispatch(.initialize)
                    setupStreams()
                }
                .fullScreenCover(isPresented: $store.state.ui.showPermissionPrompt) {
                    SmartNotificationView(program: store)
                }
                
                .fullScreenCover(isPresented: $store.state.ui.showOfflineView) {
                    UnavailableView()
                }
            }
            .ignoresSafeArea()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func setupStreams() {
        NotificationCenter.default.publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { store.dispatch(.trackingReceived($0)) }
            .store(in: &streams)
        
        NotificationCenter.default.publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { store.dispatch(.navigationReceived($0)) }
            .store(in: &streams)
    }

    private func animate() {
        withAnimation(.easeIn(duration: 0.6)) { gridOpacity = 0.12 }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
            logoScale = 1; logoOpacity = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particlesVisible = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
            taglineOffset = 0; taglineOpacity = 1
        }
    }
}

struct BlueprintGridView: View {
    var body: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 40
            ctx.stroke(gridPath(size: size, spacing: spacing),
                       with: .color(Color.white.opacity(0.3)), lineWidth: 0.5)
            ctx.stroke(gridPath(size: size, spacing: spacing * 5),
                       with: .color(Color.seAmber.opacity(0.3)), lineWidth: 1)
        }
        .ignoresSafeArea()
    }

    private func gridPath(size: CGSize, spacing: CGFloat) -> Path {
        var p = Path()
        var x: CGFloat = 0
        while x <= size.width { p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height)); x += spacing }
        var y: CGFloat = 0
        while y <= size.height { p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)); y += spacing }
        return p
    }
}

struct SplashParticle: Identifiable {
    let id = UUID()
    let x, y, size, opacity, delay: CGFloat

    static func generate(count: Int) -> [SplashParticle] {
        (0..<count).map { _ in
            SplashParticle(
                x: CGFloat.random(in: -160...160),
                y: CGFloat.random(in: -300...300),
                size: CGFloat.random(in: 3...8),
                opacity: CGFloat.random(in: 0.3...0.8),
                delay: CGFloat.random(in: 0...0.4)
            )
        }
    }
}
