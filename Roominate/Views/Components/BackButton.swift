import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 44, height: 44, alignment: .leading)
        }
    }
}
