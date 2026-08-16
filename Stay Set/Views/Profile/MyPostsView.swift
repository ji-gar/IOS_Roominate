import SwiftUI

struct MyPostsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onBack: () -> Void
    let onAddPost: () -> Void
    let onEditListing: (Post) -> Void

    @State private var listingPendingDeletion: UserListing?

    var body: some View {
        VStack(spacing: 0) {
            DetailNavBar(title: Strings.Profile.myPosts, onBack: onBack) {
                Color.clear.frame(width: 44, height: 44)
            }

            if viewModel.isLoadingListings && viewModel.listings.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.listings.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.listings) { listing in
                            ProfileListingCard(
                                listing: listing,
                                onEdit: { onEditListing(listing.post) },
                                onDelete: { listingPendingDeletion = listing }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await viewModel.loadListings()
        }
        .alert(Strings.Profile.deleteListingTitle, isPresented: deleteAlertBinding) {
            Button(Strings.Profile.deleteListing, role: .destructive) {
                guard let listing = listingPendingDeletion else { return }
                Task {
                    _ = await viewModel.deleteListing(id: listing.id)
                    listingPendingDeletion = nil
                }
            }
            Button("Cancel", role: .cancel) {
                listingPendingDeletion = nil
            }
        } message: {
            Text(Strings.Profile.deleteListingMessage)
        }
        .overlay {
            if viewModel.isDeletingListing {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                ProgressView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(Strings.Profile.noListingYet)
                .font(.system(size: AppTheme.Profile.cardSubtitleSize))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            ProfileAddPostButton(action: onAddPost)
                .padding(.horizontal, 16)
            Spacer()
        }
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { listingPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    listingPendingDeletion = nil
                }
            }
        )
    }
}
