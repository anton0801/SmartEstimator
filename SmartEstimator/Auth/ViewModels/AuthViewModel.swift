import SwiftUI
import Firebase
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()

    // Computed helpers
    var isGuest: Bool         { authState == .guest }
    var isSignedIn: Bool      { authState == .authenticated }
    var userEmail: String     { currentUser?.email ?? "" }
    var displayName: String   { currentUser?.displayName ?? userEmail.components(separatedBy: "@").first?.capitalized ?? "User" }
    var userInitials: String  {
        let name = displayName
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    var isEmailVerified: Bool { currentUser?.isEmailVerified ?? false }

    init() {
        listenToAuthChanges()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth Listener
    private func listenToAuthChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = user
                    if user.isAnonymous {
                        self?.authState = .guest
                    } else {
                        self?.authState = .authenticated
                    }
                } else {
                    self?.currentUser = nil
                    // Check if was guest before
                    if self?.authState != .unauthenticated {
                        self?.authState = .unauthenticated
                    }
                }
            }
        }
        // Give Firebase a moment to restore session
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            if self?.authState == .loading {
                self?.authState = .unauthenticated
            }
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, name: String) {
        guard validate(email: email, password: password) else { return }
        isLoading = true
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                    return
                }
                guard let user = result?.user else { return }
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name.trimmingCharacters(in: .whitespaces)
                changeRequest.commitChanges { _ in
                    self?.currentUser = Auth.auth().currentUser
                }
                user.sendEmailVerification { _ in }
            }
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        isLoading = true
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                }
            }
        }
    }

    // MARK: - Guest Sign-In
    func continueAsGuest() {
        isLoading = true
        errorMessage = nil
        Auth.auth().signInAnonymously { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                }
            }
        }
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            authState = .unauthenticated
            currentUser = nil
        } catch {
            errorMessage = "Sign out failed. Please try again."
        }
    }

    // MARK: - Reset Password
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email address."
            completion(false)
            return
        }
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    // MARK: - Update Display Name
    func updateDisplayName(_ name: String, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else { completion(false); return }
        isLoading = true
        let req = user.createProfileChangeRequest()
        req.displayName = name.trimmingCharacters(in: .whitespaces)
        req.commitChanges { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                    completion(false)
                } else {
                    self?.currentUser = Auth.auth().currentUser
                    completion(true)
                }
            }
        }
    }

    // MARK: - Delete Account
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else { completion(false); return }
        isLoading = true
        user.delete { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                    completion(false)
                } else {
                    // Clear local data
                    UserDefaults.standard.removeObject(forKey: "saved_estimates")
                    UserDefaults.standard.removeObject(forKey: "custom_materials")
                    self?.authState = .unauthenticated
                    self?.currentUser = nil
                    completion(true)
                }
            }
        }
    }

    // MARK: - Re-authenticate (required before delete)
    func reauthenticate(password: String, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser, let email = user.email else { completion(false); return }
        isLoading = true
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credential) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    // MARK: - Upgrade Guest to Full Account
    func upgradeGuest(email: String, password: String, name: String) {
        guard validate(email: email, password: password) else { return }
        guard let user = currentUser, user.isAnonymous else { return }
        isLoading = true
        errorMessage = nil
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.link(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.friendlyError(error)
                    return
                }
                if let linkedUser = result?.user {
                    let req = linkedUser.createProfileChangeRequest()
                    req.displayName = name.trimmingCharacters(in: .whitespaces)
                    req.commitChanges { _ in self?.currentUser = Auth.auth().currentUser }
                    linkedUser.sendEmailVerification { _ in }
                }
            }
        }
    }

    // MARK: - Helpers
    func clearError() { errorMessage = nil }

    private func validate(email: String, password: String) -> Bool {
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        return true
    }

    private func friendlyError(_ error: Error) -> String {
//        let code = AuthErrorCode(_nsError: error as NSError)
//        switch code.code {
//        case .emailAlreadyInUse:    return "This email is already registered. Try signing in."
//        case .invalidEmail:         return "Please enter a valid email address."
//        case .weakPassword:         return "Password is too weak. Use at least 6 characters."
//        case .wrongPassword:        return "Incorrect password. Please try again."
//        case .userNotFound:         return "No account found with this email."
//        case .networkError:         return "Network error. Check your connection and try again."
//        case .tooManyRequests:      return "Too many attempts. Please wait a moment and try again."
//        case .userDisabled:         return "This account has been disabled. Contact support."
//        case .requiresRecentLogin:  return "Please sign out and sign in again before making this change."
//        default:                    return error.localizedDescription
//        }
        return error.localizedDescription
    }
}
