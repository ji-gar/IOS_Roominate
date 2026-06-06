import SwiftUI

struct OTPInputView: View {
    let code: String
    let length: Int

    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<length, id: \.self) { index in
                if index < code.count {
                    let character = Array(code)[index]
                    Text(String(character))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(width: 24, height: 24)
                } else {
                    Circle()
                        .fill(AppTheme.disabledButton)
                        .frame(width: 16, height: 16)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
