import UIKit

enum ImageCompressor {
    /// Target size for chat uploads — keeps payloads small enough for HTTP/3 / cloud proxies.
    static let chatMaxBytes = 750_000
    static let chatMaxDimension: CGFloat = 1280

    static func chatJPEGData(from image: UIImage) -> Data? {
        compressedJPEGData(from: image, maxBytes: chatMaxBytes, maxDimension: chatMaxDimension)
    }

    static func compressedJPEGData(
        from image: UIImage,
        maxBytes: Int,
        maxDimension: CGFloat
    ) -> Data? {
        let normalized = normalizedImage(image)
        var dimension = maxDimension

        while dimension >= 480 {
            let resized = resizedImage(normalized, maxDimension: dimension)
            var quality: CGFloat = 0.82

            while quality >= 0.3 {
                if let data = resized.jpegData(compressionQuality: quality),
                   data.count <= maxBytes {
                    return data
                }
                quality -= 0.1
            }

            dimension *= 0.75
        }

        return resizedImage(normalized, maxDimension: 480).jpegData(compressionQuality: 0.3)
    }

    private static func normalizedImage(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    private static func resizedImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let largestSide = max(pixelWidth, pixelHeight)
        guard largestSide > maxDimension else { return image }

        let scale = maxDimension / largestSide
        let newSize = CGSize(width: pixelWidth * scale, height: pixelHeight * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
