import SwiftUI

// MARK: - FAQ Model

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

// MARK: - Static FAQ Data

private let faqItems: [FAQItem] = [
    FAQItem(
        question: "How do I create a new post?",
        answer: "Tap the \"+\" tab at the bottom of the screen. Choose whether you're listing a flat or looking for a flatmate, then fill in the details and submit."
    ),
    FAQItem(
        question: "How can I edit or delete a post I created?",
        answer: "Go to Profile → My Posts. Find the post you want to modify, then tap Edit to update it or Delete to remove it permanently."
    ),
    FAQItem(
        question: "Change or add an email address",
        answer: """
• Tap on the Profile icon at the bottom right of the Home screen.
• Tap Edit Info.
• Under Personal Details, tap on the email field.
• Enter your preferred email address.
• Tap Save to update your profile.
"""
    ),
    FAQItem(
        question: "How do I chat with someone?",
        answer: "Open a listing you're interested in and tap the \"Message\" button. This will start a conversation with the poster directly inside the app."
    ),
    FAQItem(
        question: "How do I report a post or user?",
        answer: "Open the post or user profile, tap the three-dot menu (⋯) in the top-right corner, and select \"Report\". Choose a reason and submit. Our team will review it shortly."
    )
]

// MARK: - View

struct HelpView: View {
    let onBack: () -> Void

    @State private var expandedID: UUID?

    var body: some View {
        profileEditContainer(title: Strings.Profile.help, onBack: onBack) {
            VStack(spacing: 0) {
                ForEach(faqItems) { item in
                    FAQRow(
                        item: item,
                        isExpanded: expandedID == item.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                expandedID = (expandedID == item.id) ? nil : item.id
                            }
                        }
                    )

                    if item.id != faqItems.last?.id {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.infoCardBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - FAQ Row

private struct FAQRow: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(alignment: .center) {
                    Text(item.question)
                        .font(.system(size: AppTheme.Profile.menuTitleSize, weight: .regular))
                        .foregroundStyle(AppTheme.primaryBlue)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                answerView
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var answerView: some View {
        Text(item.answer)
            .font(.system(size: 14))
            .foregroundStyle(AppTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
    }
}

#Preview {
    HelpView(onBack: {})
}
