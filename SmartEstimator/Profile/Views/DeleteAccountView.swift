import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var step: Step = .confirm
    @State private var password = ""
    @State private var showPass  = false

    enum Step { case confirm, reauth, deleting, done }

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()

                switch step {
                case .confirm:
                    confirmStep

                case .reauth:
                    reauthStep

                case .deleting:
                    deletingStep

                case .done:
                    doneStep
                }
            }
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if step == .confirm || step == .reauth {
                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.seNavy)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 1: Warning
    private var confirmStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Warning icon
                ZStack {
                    Circle()
                        .fill(Color.seError.opacity(0.10))
                        .frame(width: 80, height: 80)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36)).foregroundColor(.seError)
                }
                .padding(.top, 32)

                Text("Delete Your Account?")
                    .font(SEFont.title2()).foregroundColor(.seText)

                // Consequences list
                VStack(spacing: 0) {
                    ConsequenceRow(icon: "folder.fill.badge.minus",
                                   text: "All your saved estimates will be permanently deleted",
                                   color: .seError)
                    Divider().padding(.horizontal, 16)
                    ConsequenceRow(icon: "star.fill.badge.minus",
                                   text: "Your custom materials library will be removed",
                                   color: .seError)
                    Divider().padding(.horizontal, 16)
                    ConsequenceRow(icon: "person.fill.xmark",
                                   text: "Your account credentials will be erased from Firebase",
                                   color: .seError)
                    Divider().padding(.horizontal, 16)
                    ConsequenceRow(icon: "arrow.uturn.backward.circle",
                                   text: "This action cannot be undone",
                                   color: .seError)
                }
                .background(Color.white).cornerRadius(16)
                .shadow(color: Color.seNavy.opacity(0.06), radius: 8, y: 2)

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        withAnimation { step = .reauth }
                    } label: {
                        Text("I Understand — Continue")
                            .font(SEFont.headline())
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.seError)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Text("Cancel — Keep My Account")
                            .font(SEFont.headline())
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.seNavy.opacity(0.07))
                            .foregroundColor(.seNavy)
                            .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Step 2: Re-authenticate
    private var reauthStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.seAmber.opacity(0.10)).frame(width: 72, height: 72)
                    Image(systemName: "lock.fill").font(.system(size: 30)).foregroundColor(.seAmber)
                }
                Text("Confirm Your Identity")
                    .font(SEFont.title2()).foregroundColor(.seText)
                Text("Enter your password to confirm account deletion.")
                    .font(SEFont.subheadline()).foregroundColor(.seSubtext)
                    .multilineTextAlignment(.center).padding(.horizontal, 20)
            }
            .padding(.top, 32)

            if let err = authVM.errorMessage {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(.seError)
                    Text(err).font(SEFont.caption()).foregroundColor(.seError)
                    Spacer()
                }
                .padding(12).background(Color.seError.opacity(0.08)).cornerRadius(10)
                .padding(.horizontal, 20)
            }

            VStack(spacing: 14) {
                AuthField(label: "Current Password", placeholder: "Enter your password",
                          text: $password, icon: "lock.fill",
                          isSecure: !showPass, focused: false,
                          trailingIcon: showPass ? "eye.slash.fill" : "eye.fill",
                          trailingAction: { showPass.toggle() })
            }
            .padding(.horizontal, 20)
            .seCard()
            .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    authVM.clearError()
                    authVM.reauthenticate(password: password) { ok in
                        if ok {
                            withAnimation { step = .deleting }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                authVM.deleteAccount { _ in
                                    withAnimation { step = .done }
                                }
                            }
                        }
                    }
                } label: {
                    ZStack {
                        if authVM.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Delete My Account")
                                .font(SEFont.headline()).foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(password.isEmpty ? Color.seSubtext.opacity(0.3) : Color.seError)
                    .cornerRadius(14)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(password.isEmpty || authVM.isLoading)

                Button { presentationMode.wrappedValue.dismiss() } label: {
                    Text("Cancel")
                        .font(SEFont.headline())
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(Color.seNavy.opacity(0.07)).foregroundColor(.seNavy).cornerRadius(14)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 20).padding(.bottom, 30)
        }
    }

    // MARK: - Step 3: Deleting
    private var deletingStep: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView().progressViewStyle(.circular).scaleEffect(1.4).tint(.seAmber)
            Text("Deleting your account…")
                .font(SEFont.headline()).foregroundColor(.seSubtext)
            Spacer()
        }
    }

    // MARK: - Step 4: Done (auto-dismissed by authState change)
    private var doneStep: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60)).foregroundColor(.seSuccess)
            Text("Account Deleted").font(SEFont.title2())
            Text("Your account and all data have been permanently removed.")
                .font(SEFont.body()).foregroundColor(.seSubtext).multilineTextAlignment(.center).padding(.horizontal, 30)
            Spacer()
        }
    }
}

struct ConsequenceRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(color).frame(width: 24)
            Text(text).font(SEFont.caption()).foregroundColor(.seText)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}
