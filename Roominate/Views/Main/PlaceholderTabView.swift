import SwiftUI

/// Lightweight placeholder for tabs that are not yet implemented.
struct PlaceholderTabView: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.primaryBlue)
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Coming soon")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.screenBackground.ignoresSafeArea())
    }
}

struct ProfileTabView: View {
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.primaryBlue)
            Text("Profile")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Coming soon")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)

            Button("Sign Out", action: onSignOut)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.errorRed)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.screenBackground.ignoresSafeArea())
    }
}
