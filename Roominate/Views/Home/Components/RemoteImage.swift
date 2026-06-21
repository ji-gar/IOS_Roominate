import SwiftUI

/// AsyncImage wrapper that shows a neutral placeholder while loading or on failure.
struct RemoteImage: View {
    let urlString: String?
    var contentMode: ContentMode = .fill

    var body: some View {
        AsyncImage(url: urlString.flatMap(URL.init(string:))) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                placeholder
            case .empty:
                placeholder
                    .overlay(ProgressView())
            @unknown default:
                placeholder
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            AppTheme.chipBackground
            Image(systemName: "photo")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
        }
    }
}

/// Circular avatar with a person fallback.
struct AvatarView: View {
    let urlString: String?
    var size: CGFloat = 40
    var fallbackInitials: String = ""
    var style: ProfileAvatarView.ProfileAvatarStyle = .standard

    var body: some View {
        Group {
            if let urlString, !urlString.isEmpty {
                RemoteImage(urlString: urlString)
            } else {
                initialsFallback
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    @ViewBuilder
    private var initialsFallback: some View {
        ZStack {
            Circle()
                .fill(style == .settings
                    ? Color(red: 0.90, green: 0.91, blue: 0.93)
                    : Color(red: 0.88, green: 0.93, blue: 0.98))
            if !fallbackInitials.isEmpty {
                Text(String(fallbackInitials.prefix(1)))
                    .font(.system(size: size * 0.38, weight: .medium))
                    .foregroundStyle(style == .settings ? AppTheme.textPrimary : AppTheme.primaryBlue)
            } else {
                Image(systemName: "person.fill")
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
}
