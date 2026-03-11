import SwiftUI

/// Settings tab is now merged into ProfileView.
/// This file is kept as a thin redirect to avoid build errors
/// if any NavigationLink still points to SettingsView.
struct SettingsView: View {
    var body: some View {
        ProfileView()
    }
}
