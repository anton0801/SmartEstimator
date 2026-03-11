import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var displayName:    String = ""
    @Published var isEditingName:  Bool = false
    @Published var showDeleteFlow: Bool = false
    @Published var showSignOutAlert: Bool = false

    // Delete re-auth state
    @Published var reauthEmail:    String = ""
    @Published var reauthPassword: String = ""
    @Published var reauthStep:     ReauthStep = .confirm

    enum ReauthStep { case confirm, reauth }

    private var authVM: AuthViewModel

    init(authVM: AuthViewModel) {
        self.authVM = authVM
        self.displayName = authVM.displayName
    }

    func startEditingName() {
        displayName = authVM.displayName
        isEditingName = true
    }

    func saveName() {
        Task {
            await authVM.updateDisplayName(displayName) { _ in
            }
            isEditingName = false
        }
    }

    func signOut() {
        authVM.signOut()
    }

    func beginDeleteFlow() {
        reauthStep = .confirm
        reauthEmail = authVM.userEmail
        reauthPassword = ""
        showDeleteFlow = true
    }

    func proceedDelete() {
        Task {
            // For accounts that need re-auth
            await authVM.deleteAccount { _ in }
            showDeleteFlow = false
        }
    }

    func confirmDeleteWithoutReauth() {
        Task {
            await authVM.deleteAccount { _ in }
            showDeleteFlow = false
        }
    }
}
