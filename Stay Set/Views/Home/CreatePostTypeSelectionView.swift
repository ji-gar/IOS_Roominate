import SwiftUI

struct CreatePostTypeSelectionView: View {
    let onSelect: (Bool) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("What Type of Post you want to create")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 16) {
                    postTypeCard(
                        title: "I have a Stay to offer",
                        subtitle: "You already have a flat, just need a roommate",
                        imageName: HomeAssets.flatmateEmptyIllustration,
                        fallbackSystemImage: "person.crop.circle",
                        postType: true
                    )

                    postTypeCard(
                        title: "I am looking for Stay and flat mate",
                        subtitle: "You don't have a flat yet, and want to find someone to stay with)",
                        imageName: HomeAssets.flatEmptyIllustration,
                        fallbackSystemImage: "house",
                        postType: false
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
        }
    }

    private func postTypeCard(
        title: String,
        subtitle: String,
        imageName: String,
        fallbackSystemImage: String,
        postType: Bool
    ) -> some View {
        Button {
            onSelect(postType)
        } label: {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                cardIllustration(imageName: imageName, fallbackSystemImage: fallbackSystemImage)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.infoCardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func cardIllustration(imageName: String, fallbackSystemImage: String) -> some View {
        if !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
        } else {
            Image(systemName: fallbackSystemImage)
                .font(.system(size: 40))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(AppTheme.primaryBlue)
                .frame(width: 72, height: 72)
        }
    }
}
