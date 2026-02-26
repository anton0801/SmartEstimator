import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "CHF", "JPY", "UAH", "PLN"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // App card
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient.seAmberGradient).frame(width: 64, height: 64)
                                Image(systemName: "house.fill").font(.system(size: 28)).foregroundColor(.white)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Smart Estimator").font(SEFont.headline()).foregroundColor(.seText)
                                Text("Version 1.0.0 · Free").font(SEFont.caption()).foregroundColor(.seSubtext)
                            }
                            Spacer()
                        }
                        .seCard().padding(.horizontal, 20)

                        // Currency
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Currency", systemImage: "dollarsign.circle")
                                .font(SEFont.headline()).foregroundColor(.seText)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(currencies, id: \.self) { cur in
                                    Button {
                                        withAnimation { appState.currency = cur }
                                    } label: {
                                        Text(cur).font(SEFont.subheadline())
                                            .foregroundColor(appState.currency == cur ? .white : .seNavy)
                                            .padding(.vertical, 8).frame(maxWidth: .infinity)
                                            .background(appState.currency == cur ? Color.seNavy : Color.seNavy.opacity(0.08))
                                            .cornerRadius(10)
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }
                        .seCard().padding(.horizontal, 20)

                        // Waste %
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Waste Buffer", systemImage: "arrow.triangle.2.circlepath")
                                    .font(SEFont.headline()).foregroundColor(.seText)
                                Spacer()
                                Text("\(Int(appState.wastePercentage))%")
                                    .font(SEFont.title2()).foregroundColor(.seAmber)
                            }
                            Slider(value: $appState.wastePercentage, in: 5...25, step: 1)
                                .accentColor(.seAmber)
                            HStack {
                                Text("5% — Precision cutting").font(SEFont.caption()).foregroundColor(.seSubtext)
                                Spacer()
                                Text("25% — Complex layout").font(SEFont.caption()).foregroundColor(.seSubtext)
                            }
                            Text("Extra material for cuts, waste, and errors. 10-15% is standard.")
                                .font(SEFont.caption()).foregroundColor(.seSubtext)
                                .padding(10).background(Color.seAmber.opacity(0.08)).cornerRadius(8)
                        }
                        .seCard().padding(.horizontal, 20)

                        // Data management
                        VStack(spacing: 0) {
                            SettingsRow(icon: "trash.fill", label: "Clear All Estimates",
                                        iconColor: .seError, isDanger: true) {
                                UserDefaults.standard.removeObject(forKey: "saved_estimates")
                                PersistenceService.shared.loadEstimates()
                            }
                            Divider().padding(.horizontal, 16)
                            SettingsRow(icon: "arrow.counterclockwise", label: "Reset Custom Materials",
                                        iconColor: .seSubtext, isDanger: false) {
                                UserDefaults.standard.removeObject(forKey: "custom_materials")
                                PersistenceService.shared.loadCustomMaterials()
                            }
                            Divider().padding(.horizontal, 16)
                            SettingsRow(icon: "arrow.left.square", label: "Restart Onboarding",
                                        iconColor: .seNavy, isDanger: false) {
                                appState.hasCompletedOnboarding = false
                            }
                        }
                        .background(Color.white).cornerRadius(16)
                        .shadow(color: Color.seNavy.opacity(0.06), radius: 8, y: 2)
                        .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            SettingsRow(icon: "info.circle", label: "About Smart Estimator",
                                        iconColor: .seNavy, isDanger: false) {}
                            Divider().padding(.horizontal, 16)
                            SettingsRow(icon: "hand.thumbsup", label: "Rate the App",
                                        iconColor: .seAmber, isDanger: false) {}
                        }
                        .background(Color.white).cornerRadius(16)
                        .shadow(color: Color.seNavy.opacity(0.06), radius: 8, y: 2)
                        .padding(.horizontal, 20).padding(.bottom, 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Settings").navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }
}

struct SettingsRow: View {
    let icon: String
    let label: String
    let iconColor: Color
    let isDanger: Bool
    let action: () -> Void
    @State private var showConfirm = false

    var body: some View {
        Button {
            if isDanger { showConfirm = true } else { action() }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(iconColor.opacity(0.12)).frame(width: 34, height: 34)
                    Image(systemName: icon).font(.system(size: 16)).foregroundColor(iconColor)
                }
                Text(label).font(SEFont.body()).foregroundColor(isDanger ? .seError : .seText)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(.seSubtext)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .buttonStyle(ScaleButtonStyle())
        .confirmationDialog("Are you sure?", isPresented: $showConfirm) {
            Button("Confirm", role: .destructive) { action() }
        }
    }
}
