import SwiftUI

struct ConversationRowView: View {
    let conversation: ChatConversation
    let myUserId: Int

    private var otherName: String {
        if let initiatorId = conversation.initiatorId, initiatorId == myUserId {
            return conversation.receiver?.name ?? "Unknown"
        }
        return conversation.initiator?.name ?? "Unknown"
    }

    private var avatarLetter: String {
        String(otherName.prefix(1)).uppercased()
    }

    private var lastMessagePreview: String {
        guard let preview = conversation.latestMessage?.previewText else {
            return "No messages yet"
        }

        if let senderId = conversation.latestMessage?.resolvedSenderId,
           senderId == myUserId,
           myUserId > 0 {
            return "You: \(preview)"
        }
        return preview
    }

    private var timeText: String {
        let raw = conversation.latestMessage?.updatedAt
            ?? conversation.latestMessage?.createdAt
            ?? conversation.updatedAt
            ?? ""
        return raw.isEmpty ? "" : ChatDateFormatter.conversationListTime(from: raw)
    }

    private static let gradients: [LinearGradient] = [
        LinearGradient(colors: [Color(hex: "#4776E6"), Color(hex: "#8E54E9")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "#0072FF"), Color(hex: "#00C6FF")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "#11998e"), Color(hex: "#38ef7d")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "#FF512F"), Color(hex: "#F09819")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "#c94b4b"), Color(hex: "#4b134f")], startPoint: .topLeading, endPoint: .bottomTrailing),
    ]

    private var gradient: LinearGradient {
        let index = abs(otherName.hashValue) % Self.gradients.count
        return Self.gradients[index]
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 50, height: 50)
                Text(avatarLetter)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(otherName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                        .lineLimit(1)
                    Spacer()
                    Text(timeText)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "#9EA3B0"))
                }
                Text(lastMessagePreview)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "#6B7280"))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
