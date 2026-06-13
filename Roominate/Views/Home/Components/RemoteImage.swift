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

    var body: some View {
        RemoteImage(urlString: urlString)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay {
                if urlString == nil {
                    Image(systemName: "person.fill")
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
    }
}
