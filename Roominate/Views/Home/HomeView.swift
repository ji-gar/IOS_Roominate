import SwiftUI

struct HomeView: View {
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.primaryBlue)

            Text("Welcome to \(Strings.App.name)")
                .font(.system(size: 24, weight: .bold))

            Text("You're all set! Home screen coming soon.")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button("Sign Out", action: onSignOut)
                .foregroundStyle(AppTheme.primaryBlue)
        }
        .padding(AppTheme.horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    HomeView(onSignOut: {})
}
