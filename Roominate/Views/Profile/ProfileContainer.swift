import SwiftUI

@ViewBuilder
func profileContainer<Content: View>(
    onBack: @escaping () -> Void,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(spacing: 0) {
        HStack {
            BackButton(action: onBack)
            Spacer()
            Text(Strings.Profile.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)

        ScrollView {
            content()
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.top, 24)
                .padding(.bottom, 32)
        }
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarHidden(true)
}
