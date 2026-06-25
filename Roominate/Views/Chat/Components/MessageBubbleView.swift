import SwiftUI

struct MessageBubbleView: View {
    let message: MessageItem
    let isSentByMe: Bool

    private var bodyText: String { message.body ?? "" }
    private var timeText: String {
        guard let raw = message.createdAt else { return "" }
        return ChatDateFormatter.messageBubbleTime(from: raw)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isSentByMe { Spacer(minLength: 60) }

            VStack(alignment: isSentByMe ? .trailing : .leading, spacing: 3) {
                Text(timeText)
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "#9EA3B0"))

                bubbleContent
                    .frame(maxWidth: 280, alignment: isSentByMe ? .trailing : .leading)
            }

            if !isSentByMe { Spacer(minLength: 60) }
        }
    }

    @ViewBuilder
    private var bubbleContent: some View {
        if message.isImageMessage {
            if let url = message.resolvedMediaURL {
                RemoteImage(urlString: url, contentMode: .fill)
                    .frame(width: 220, height: 160)
                    .clipped()
                    .clipShape(BubbleShape(isSentByMe: isSentByMe))
                    .overlay {
                        BubbleShape(isSentByMe: isSentByMe)
                            .stroke(isSentByMe ? Color.clear : Color(hex: "#E5E7EB"), lineWidth: 1)
                    }
                    .contextMenu {
                        if let shareURL = URL(string: url) {
                            ShareLink(item: shareURL) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
            } else {
                imagePlaceholder
            }
        } else {
            Text(bodyText)
                .font(.system(size: 15))
                .foregroundStyle(isSentByMe ? .white : Color(hex: "#1A1A2E"))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isSentByMe
                        ? Color(hex: "#15489E")
                        : Color(hex: "#F1F2F4")
                )
                .clipShape(BubbleShape(isSentByMe: isSentByMe))
        }
    }

    private var imagePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(isSentByMe ? Color(hex: "#15489E") : Color(hex: "#F1F2F4"))
            VStack(spacing: 6) {
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundStyle(isSentByMe ? .white.opacity(0.9) : Color(hex: "#6B7280"))
                Text("Photo")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSentByMe ? .white.opacity(0.9) : Color(hex: "#6B7280"))
            }
        }
        .frame(width: 160, height: 120)
        .clipShape(BubbleShape(isSentByMe: isSentByMe))
    }
}

// MARK: - Bubble Shape

private struct BubbleShape: Shape {
    let isSentByMe: Bool
    let radius: CGFloat = 18
    let tailRadius: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tl = radius
        let tr = isSentByMe ? radius : radius
        let bl = isSentByMe ? radius : tailRadius
        let br = isSentByMe ? tailRadius : radius

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                    radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                    radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                    radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                    radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Date Formatter

enum ChatDateFormatter {
    private static let isoParser: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let isoParserNoFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static let fallbackParser: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    private static let bubbleFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    private static let listTodayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    private static let listOldFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM"
        return f
    }()

    static func parse(_ raw: String) -> Date? {
        isoParser.date(from: raw)
            ?? isoParserNoFrac.date(from: raw)
            ?? fallbackParser.date(from: raw)
    }

    static func messageBubbleTime(from raw: String) -> String {
        guard let date = parse(raw) else { return "" }
        return bubbleFormatter.string(from: date)
    }

    static func conversationListTime(from raw: String) -> String {
        guard let date = parse(raw) else { return "" }
        if Calendar.current.isDateInToday(date) {
            return listTodayFormatter.string(from: date)
        }
        return listOldFormatter.string(from: date)
    }
}

// MARK: - Hex Color helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
