import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var estimateVM = EstimateViewModel()
    @StateObject private var libraryVM  = MaterialLibraryViewModel()
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NewEstimateView()
                    .tag(0)
                MyEstimatesView()
                    .environmentObject(estimateVM)
                    .tag(1)
                MaterialLibraryView()
                    .environmentObject(libraryVM)
                    .tag(2)
                ProfileView()
                    .environmentObject(authVM)
                    .environmentObject(appState)
                    .tag(3)
            }
            SETabBar(selectedTab: $selectedTab, isGuest: authVM.isGuest)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct SETabBar: View {
    @Binding var selectedTab: Int
    let isGuest: Bool

    var tabs: [(icon: String, label: String, guestIcon: String?)] {
        [
            ("plus.circle.fill",     "New Estimate", nil),
            ("folder.fill",          "My Estimates", nil),
            ("square.grid.3x3.fill", "Library",      nil),
            ("person.crop.circle.fill", "Profile",   isGuest ? "person.fill.questionmark" : nil)
        ]
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { i in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = i }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Image(systemName: tabs[i].guestIcon ?? tabs[i].icon)
                                .font(.system(size: 22, weight: selectedTab == i ? .bold : .regular))
                                .foregroundColor(selectedTab == i ? .seAmber : .seSubtext)
                                .scaleEffect(selectedTab == i ? 1.15 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)
                            // Guest dot indicator on Profile tab
                            if i == 3 && isGuest {
                                Circle()
                                    .fill(Color.seAmber)
                                    .frame(width: 7, height: 7)
                                    .offset(x: 10, y: -10)
                            }
                        }
                        Text(tabs[i].label)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(selectedTab == i ? .seAmber : .seSubtext)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(
            Color.white
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .shadow(color: Color.seNavy.opacity(0.12), radius: 20, y: -5)
        )
    }
}
