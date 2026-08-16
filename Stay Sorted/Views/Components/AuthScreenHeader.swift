import SwiftUI

struct AuthScreenHeader: View {
    let onBack: () -> Void

    var body: some View {
        HStack {
            BackButton(action: onBack)
            Spacer()
        }
        .padding(.horizontal, AppTheme.horizontalPadding)
        .frame(minHeight: 44)
    }
}
