import SwiftUI

enum HomeAssets {
    /// Add flat empty-state illustration asset name here when available.
    static let flatEmptyIllustration = "createPostFlat"
    /// Add flatmate empty-state illustration asset name here when available.
    static let flatmateEmptyIllustration = "createPostFlatmate"
}

struct HomeEmptyStateView: View {
    let segment: ListingSegment
    let isCreatingPost: Bool
    let onAddPost: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            illustration
                .frame(height: 180)

            VStack(spacing: 8) {
                Text("No posts yet. Let's find your flatmate!")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Start finding a flat or flatmate by creating your first post.")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            Button(action: onAddPost) {
                HStack(spacing: 8) {
                    if isCreatingPost {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Add post")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isCreatingPost)
            .padding(.horizontal, 48)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    @ViewBuilder
    private var illustration: some View {
        let assetName = segment == .flat
            ? HomeAssets.flatEmptyIllustration
            : HomeAssets.flatmateEmptyIllustration

        if !assetName.isEmpty {
            Image(assetName)
                .resizable()
                .scaledToFit()
        } else {
            illustrationPlaceholder
        }
    }

    private var illustrationPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.chipBackground)
                .frame(width: 220, height: 160)

            Image(systemName: segment == .flat ? "house.fill" : "person.2.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.35))
        }
    }
}
