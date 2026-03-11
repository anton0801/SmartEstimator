import Foundation

enum AuthState: Equatable {
    case loading
    case unauthenticated
    case authenticated
    case guest

    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.unauthenticated, .unauthenticated),
             (.authenticated, .authenticated),
             (.guest, .guest): return true
        default: return false
        }
    }
}
