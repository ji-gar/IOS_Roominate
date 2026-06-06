import SwiftUI

struct AuthTextField: View {
    enum FieldState {
        case normal
        case focused
        case error(String)
    }

    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var state: FieldState = .normal
    @State private var isPasswordVisible = false

    private var borderColor: Color {
        switch state {
        case .normal:
            return AppTheme.fieldBorder
        case .focused:
            return AppTheme.primaryBlue
        case .error:
            return AppTheme.errorRed
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .focused:
            return AppTheme.activeFieldBackground
        default:
            return .white
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Group {
                    if isSecure && !isPasswordVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.textPrimary)

                if isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))

            if case .error(let message) = state {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.errorRed)
            }
        }
    }
}
