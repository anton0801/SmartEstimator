import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appState: ApplicationState
    @State private var showSignOut       = false
    @State private var showDeleteAccount = false
    @State private var showEditName      = false
    @State private var showUpgradeGuest  = false
    @State private var editedName        = ""
    @State private var saveNameSuccess   = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // ── Avatar card ──
                        AvatarCard(authVM: authVM)
                            .staggerAppear(index: 0)

                        // ── Guest upgrade banner ──
                        if authVM.isGuest {
                            GuestUpgradeBanner {
                                showUpgradeGuest = true
                            }
                            .staggerAppear(index: 1)
                            .padding(.horizontal, 20)
                        }

                        // ── Account section ──
                        if !authVM.isGuest {
                            VStack(spacing: 0) {
                                ProfileSectionHeader(title: "Account")
                                ProfileRow(icon: "person.fill", label: "Display Name",
                                           value: authVM.displayName, color: .seNavy) {
                                    editedName = authVM.displayName
                                    showEditName = true
                                }
                                Divider().padding(.horizontal, 16)
                                ProfileRow(icon: "envelope.fill", label: "Email",
                                           value: authVM.userEmail, color: .seNavy)
                                Divider().padding(.horizontal, 16)
                                ProfileRow(icon: "checkmark.shield.fill",
                                           label: "Email Verified",
                                           value: authVM.isEmailVerified ? "Verified ✓" : "Not verified",
                                           valueColor: authVM.isEmailVerified ? .seSuccess : .seAmber,
                                           color: authVM.isEmailVerified ? .seSuccess : .seAmber)
                            }
                            .background(Color.white).cornerRadius(16)
                            .shadow(color: Color.seNavy.opacity(0.06), radius: 8, y: 2)
                            .padding(.horizontal, 20)
                            .staggerAppear(index: 2)
                        }

                        // ── App preferences ──
                        VStack(spacing: 0) {
                            ProfileSectionHeader(title: "Preferences")
                            CurrencyRow(currency: $appState.currency)
                            Divider().padding(.horizontal, 16)
                            WasteRow(waste: $appState.wastePercentage)
                        }
                        .background(Color.white).cornerRadius(16)
                        .shadow(color: Color.seNavy.opacity(0.06), radius: 8, y: 2)
                        .padding(.horizontal, 20)
                        .staggerAppear(index: 3)

                        // ── Data section ──
                        VStack(spacing: 0) {
                            ProfileSectionHeader(title: "Data")
                            ProfileActionRow(icon: "trash.fill", label: "Clear All Estimates",
                                             color: .seError) {
                                UserDefaults.standard.removeObject(forKey: "saved_estimates")
                                PersistenceMainService.shared.loadEstimates()
                            }
                            Divider().padding(.horizontal, 16)
                            ProfileActionRow(icon: "arrow.counterclockwise", label: "Reset Custom Materials",
                                             color: .seSubtext) {
                                UserDefaults.standard.removeObject(forKey: "custom_materials")
                                PersistenceMainService.shared.loadCustomMaterials()
                            }
                        }
                        .background(Color.white).cornerRadius(16)
                        .shadow(color: Color.seNavy.opacity(0.06), radius: 8, y: 2)
                        .padding(.horizontal, 20)
                        .staggerAppear(index: 4)

                        // ── Auth actions ──
                        VStack(spacing: 12) {
                            // Sign Out
                            Button { showSignOut = true } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text(authVM.isGuest ? "Exit Guest Mode" : "Sign Out")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .background(Color.seNavy.opacity(0.08))
                                .foregroundColor(.seNavy)
                                .cornerRadius(14)
                            }
                            .buttonStyle(ScaleButtonStyle())

                            // Delete account
                            if !authVM.isGuest {
                                Button { showDeleteAccount = true } label: {
                                    HStack {
                                        Image(systemName: "person.fill.xmark")
                                        Text("Delete Account")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity).frame(height: 52)
                                    .background(Color.seError.opacity(0.08))
                                    .foregroundColor(.seError)
                                    .cornerRadius(14)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .staggerAppear(index: 5)

                        // App version
                        Text("Smart Estimator v1.1.0 · Free")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.seSubtext.opacity(0.6))
                            .padding(.bottom, 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            // Sign out confirmation
            .confirmationDialog(
                authVM.isGuest ? "Exit Guest Mode?" : "Sign Out?",
                isPresented: $showSignOut, titleVisibility: .visible
            ) {
                Button(authVM.isGuest ? "Exit & Lose Data" : "Sign Out", role: .destructive) {
                    authVM.signOut()
                }
            } message: {
                Text(authVM.isGuest
                     ? "Your guest data is stored only on this device. Exiting will delete it permanently."
                     : "You will be returned to the sign-in screen.")
            }
            // Delete account sheet
            .sheet(isPresented: $showDeleteAccount) {
                DeleteAccountView().environmentObject(authVM)
            }
            // Edit name sheet
            .sheet(isPresented: $showEditName) {
                EditNameView(currentName: authVM.displayName).environmentObject(authVM)
            }
            // Upgrade guest sheet
            .sheet(isPresented: $showUpgradeGuest) {
                UpgradeGuestView().environmentObject(authVM)
            }
            .overlay(alignment: .top) {
                if let err = authVM.errorMessage {
                    ErrorBanner(message: err) { authVM.clearError() }
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Avatar Card
struct AvatarCard: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var appear = false

    var body: some View {
        ZStack {
            LinearGradient.seNavyGradient
            BlueprintGridView().opacity(0.07)

            VStack(spacing: 14) {
                // Avatar circle
                ZStack {
                    Circle()
                        .fill(LinearGradient.seAmberGradient)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.seAmber.opacity(0.4), radius: 12, y: 4)
                    if authVM.isGuest {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 32)).foregroundColor(.white)
                    } else {
                        Text(authVM.userInitials)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(appear ? 1 : 0.6)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1), value: appear)

                VStack(spacing: 4) {
                    Text(authVM.isGuest ? "Guest User" : authVM.displayName)
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundColor(.white)
                    if !authVM.isGuest {
                        Text(authVM.userEmail)
                            .font(SEFont.caption())
                            .foregroundColor(.white.opacity(0.65))
                    } else {
                        Text("Data saved on device only")
                            .font(SEFont.caption())
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 10)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: appear)

                // Guest badge / verified badge
                if authVM.isGuest {
                    GuestBadge()
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: appear)
                }
            }
            .padding(.vertical, 28)
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .onAppear { appear = true }
    }
}

struct GuestBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 12))
            Text("Guest Mode — sync unavailable")
                .font(.system(size: 12, weight: .medium, design: .rounded))
        }
        .foregroundColor(Color.seAmber)
        .padding(.horizontal, 14).padding(.vertical, 7)
        .background(Color.seAmber.opacity(0.15))
        .cornerRadius(20)
    }
}

// MARK: - Guest Upgrade Banner
struct GuestUpgradeBanner: View {
    let action: () -> Void
    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.seAmber.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .scaleEffect(pulse ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 20)).foregroundColor(.seAmber)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Upgrade to Full Account")
                        .font(SEFont.headline()).foregroundColor(.seNavy)
                    Text("Keep your data & sync across devices")
                        .font(SEFont.caption()).foregroundColor(.seSubtext)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.seAmber)
            }
            .padding(14)
            .background(Color.seAmber.opacity(0.07))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.seAmber.opacity(0.25)))
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear { pulse = true }
    }
}

// MARK: - Section Header
struct ProfileSectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.seSubtext)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 6)
    }
}

// MARK: - Profile Row (display)
struct ProfileRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .seSubtext
    var color: Color = .seNavy
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.10)).frame(width: 34, height: 34)
                    Image(systemName: icon).font(.system(size: 15)).foregroundColor(color)
                }
                Text(label).font(SEFont.body()).foregroundColor(.seText)
                Spacer()
                Text(value)
                    .font(SEFont.caption()).foregroundColor(valueColor)
                    .lineLimit(1)
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold)).foregroundColor(.seSubtext.opacity(0.5))
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .buttonStyle(action != nil ? ScaleButtonStyle() : ScaleButtonStyle())
        .disabled(action == nil)
    }
}

// MARK: - Action Row (with confirmation)
struct ProfileActionRow: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    @State private var showConfirm = false

    var body: some View {
        Button { showConfirm = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.10)).frame(width: 34, height: 34)
                    Image(systemName: icon).font(.system(size: 15)).foregroundColor(color)
                }
                Text(label).font(SEFont.body()).foregroundColor(color == .seSubtext ? .seText : color)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold)).foregroundColor(.seSubtext.opacity(0.5))
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .buttonStyle(ScaleButtonStyle())
        .confirmationDialog("Are you sure?", isPresented: $showConfirm) {
            Button("Confirm", role: .destructive) { action() }
        }
    }
}

// MARK: - Currency Row
struct CurrencyRow: View {
    @Binding var currency: String
    let currencies = ["USD","EUR","GBP","CAD","AUD","CHF","JPY","UAH","PLN"]
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button { withAnimation(.spring(response: 0.3)) { expanded.toggle() } } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.seAmber.opacity(0.10)).frame(width: 34, height: 34)
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 15)).foregroundColor(.seAmber)
                    }
                    Text("Currency").font(SEFont.body()).foregroundColor(.seText)
                    Spacer()
                    Text(currency).font(SEFont.caption()).foregroundColor(.seSubtext)
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold)).foregroundColor(.seSubtext.opacity(0.5))
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }
            .buttonStyle(ScaleButtonStyle())

            if expanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(currencies, id: \.self) { cur in
                            Button { withAnimation { currency = cur } } label: {
                                Text(cur)
                                    .font(SEFont.caption())
                                    .foregroundColor(currency == cur ? .white : .seNavy)
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(currency == cur ? Color.seNavy : Color.seNavy.opacity(0.07))
                                    .cornerRadius(20)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 12)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Waste Row
struct WasteRow: View {
    @Binding var waste: Double

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.seNavy.opacity(0.08)).frame(width: 34, height: 34)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 15)).foregroundColor(.seNavy)
                }
                Text("Waste Buffer").font(SEFont.body()).foregroundColor(.seText)
                Spacer()
                Text("\(Int(waste))%").font(SEFont.caption()).foregroundColor(.seAmber).fontWeight(.semibold)
            }
            .padding(.horizontal, 16).padding(.top, 12)

            Slider(value: $waste, in: 5...25, step: 1)
                .accentColor(.seAmber)
                .padding(.horizontal, 16).padding(.bottom, 12)
        }
    }
}
