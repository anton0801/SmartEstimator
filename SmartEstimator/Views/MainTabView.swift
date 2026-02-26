import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var estimateVM = EstimateViewModel()
    @StateObject private var libraryVM  = MaterialLibraryViewModel()
    @EnvironmentObject var appState: AppState

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
                SettingsView()
                    .tag(3)
            }
            SETabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct SETabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, label: String)] = [
        ("plus.circle.fill",     "New Estimate"),
        ("folder.fill",          "My Estimates"),
        ("square.grid.3x3.fill", "Library"),
        ("gearshape.fill",       "Settings")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { i in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = i }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[i].icon)
                            .font(.system(size: 22, weight: selectedTab == i ? .bold : .regular))
                            .foregroundColor(selectedTab == i ? .seAmber : .seSubtext)
                            .scaleEffect(selectedTab == i ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)
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
