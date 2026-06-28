import SwiftUI

/// Loads remote images with optional auth headers for protected storage URLs.
struct RemoteImage: View {
    let urlString: String?
    var contentMode: ContentMode = .fill

    @State private var loadedImage: UIImage?
    @State private var didFail = false

    var body: some View {
        Group {
            if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if didFail {
                placeholder
            } else {
                placeholder
                    .overlay(ProgressView())
            }
        }
        .task(id: urlString) {
            await loadImage()
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

    @MainActor
    private func loadImage() async {
        loadedImage = nil
        didFail = false

        guard let urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            didFail = true
            return
        }

        var request = URLRequest(url: url)
        request.setValue("image/*, */*", forHTTPHeaderField: "Accept")
        if let token = TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode),
                  let image = UIImage(data: data) else {
                didFail = true
                return
            }
            loadedImage = image
        } catch {
            didFail = true
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
