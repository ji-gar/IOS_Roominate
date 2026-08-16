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
