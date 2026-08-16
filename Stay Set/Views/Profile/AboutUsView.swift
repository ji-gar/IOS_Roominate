import SwiftUI

struct AboutUsView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            DetailNavBar(title: Strings.Profile.aboutUs, onBack: onBack) {
                Color.clear.frame(width: 44, height: 44)
            }

            ScrollView {
                Text(Strings.Profile.aboutUsDescription)
                    .font(.system(size: AppTheme.Profile.fieldInputSize))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
