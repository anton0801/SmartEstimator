import SwiftUI

struct EditNameView: View {
    let currentName: String
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var saved = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.seNavy.opacity(0.08)).frame(width: 72, height: 72)
                            Image(systemName: "pencil").font(.system(size: 30)).foregroundColor(.seNavy)
                        }
                        Text("Edit Display Name").font(SEFont.title2())
                    }
                    .padding(.top, 20)

                    VStack(spacing: 14) {
                        AuthField(label: "Display Name", placeholder: "Your name",
                                  text: $name, icon: "person.fill", focused: false)
                    }
                    .seCard().padding(.horizontal, 20)

                    if saved {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.seSuccess)
                            Text("Name updated successfully!").font(SEFont.subheadline()).foregroundColor(.seSuccess)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    if let err = authVM.errorMessage {
                        Text(err).font(SEFont.caption()).foregroundColor(.seError)
                            .padding(10).background(Color.seError.opacity(0.08)).cornerRadius(8).padding(.horizontal, 20)
                    }

                    Spacer()

                    Button {
                        authVM.updateDisplayName(name) { ok in
                            if ok {
                                withAnimation { saved = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            if authVM.isLoading { ProgressView().tint(.white) }
                            else { Label("Save Name", systemImage: "checkmark").font(SEFont.headline()).foregroundColor(.white) }
                        }
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(name.trimmingCharacters(in: .whitespaces).isEmpty ?
                            LinearGradient(colors: [Color.seSubtext.opacity(0.3), Color.seSubtext.opacity(0.3)], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient.seAmberGradient)
                        .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || authVM.isLoading)
                    .padding(.horizontal, 20).padding(.bottom, 30)
                }
                .animation(.spring(response: 0.3), value: saved)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .semibold)).foregroundColor(.seNavy)
                    }
                }
            }
            .onAppear { name = currentName }
        }
    }
}

// MARK: - Upgrade Guest View
struct UpgradeGuestView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name        = ""
    @State private var email       = ""
    @State private var password    = ""
    @State private var showPass    = false
    @State private var fieldError: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle().fill(Color.seAmber.opacity(0.12)).frame(width: 72, height: 72)
                                Image(systemName: "icloud.and.arrow.up")
                                    .font(.system(size: 30)).foregroundColor(.seAmber)
                            }
                            Text("Upgrade to Full Account").font(SEFont.title2())
                            Text("Your current guest data is preserved.\nCreate an account to sync across devices.")
                                .font(SEFont.subheadline()).foregroundColor(.seSubtext)
                                .multilineTextAlignment(.center).padding(.horizontal, 20)
                        }
                        .padding(.top, 20)

                        if let err = fieldError ?? authVM.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.seError)
                                Text(err).font(SEFont.caption()).foregroundColor(.seError)
                                Spacer()
                            }
                            .padding(12).background(Color.seError.opacity(0.08)).cornerRadius(10)
                        }

                        VStack(spacing: 14) {
                            AuthField(label: "Full Name", placeholder: "Jane Smith",
                                      text: $name, icon: "person.fill", focused: false)
                            AuthField(label: "Email", placeholder: "you@example.com",
                                      text: $email, icon: "envelope.fill",
                                      keyboard: .emailAddress, focused: false)
                            AuthField(label: "Password", placeholder: "Min. 6 characters",
                                      text: $password, icon: "lock.fill",
                                      isSecure: !showPass, focused: false,
                                      trailingIcon: showPass ? "eye.slash.fill" : "eye.fill",
                                      trailingAction: { showPass.toggle() })
                        }
                        .seCard()

                        if !password.isEmpty { PasswordStrengthView(password: password) }

                        Button {
                            fieldError = nil; authVM.clearError()
                            if name.trimmingCharacters(in: .whitespaces).isEmpty {
                                fieldError = "Please enter your name."; return
                            }
                            authVM.upgradeGuest(email: email, password: password, name: name)
                        } label: {
                            ZStack {
                                if authVM.isLoading { ProgressView().tint(.white) }
                                else { Label("Create Account", systemImage: "checkmark.circle.fill").font(SEFont.headline()).foregroundColor(.white) }
                            }
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(isValid ?
                                LinearGradient.seAmberGradient :
                                LinearGradient(colors: [Color.seSubtext.opacity(0.4), Color.seSubtext.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14).shadow(color: isValid ? Color.seAmber.opacity(0.35) : .clear, radius: 10, y: 4)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .disabled(!isValid || authVM.isLoading)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20).padding(.top, 16)
                    .animation(.spring(response: 0.3), value: fieldError)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .semibold)).foregroundColor(.seNavy)
                    }
                }
            }
            .onChange(of: authVM.authState) { state in
                if state == .authenticated { presentationMode.wrappedValue.dismiss() }
            }
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && password.count >= 6
    }
}
