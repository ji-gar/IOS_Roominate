import SwiftUI

/// Sticky bottom bar with a square favorite button and a primary "I am Interested" CTA.
struct DetailBottomBar: View {
    let isFavorite: Bool
    var isLoading: Bool = false
    let onToggleFavorite: () -> Void
    let onInterested: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundStyle(isFavorite ? AppTheme.errorRed : AppTheme.textPrimary)
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Button(action: onInterested) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                    } else {
                        Image(systemName: "message.fill")
                        Text("I am Interested")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isLoading ? AppTheme.primaryBlue.opacity(0.7) : AppTheme.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

/// Custom navigation bar used on the detail screens (back + title + trailing).
struct DetailNavBar<Trailing: View>: View {
    let title: String
    let onBack: () -> Void
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 8) {
            BackButton(action: onBack)
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
    }
}
