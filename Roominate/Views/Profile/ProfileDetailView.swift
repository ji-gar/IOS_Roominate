import SwiftUI

struct ProfileDetailView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onBack: () -> Void
    let onEditPersonalInfo: () -> Void
    let onEditContact: () -> Void
    let onEditAboutMe: () -> Void
    let onAddPost: () -> Void
    let onEditListing: (Post) -> Void

    @State private var listingPendingDeletion: UserListing?

    var body: some View {
        VStack(spacing: 0) {
            DetailNavBar(title: Strings.Profile.title, onBack: onBack) {
                Color.clear.frame(width: 44, height: 44)
            }

            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    basicInformationSection
                    contactSection
                    aboutSection
                    listingSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
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

    private var profileHeader: some View {
        VStack(spacing: 8) {
            ProfileAvatarView(
                profile: viewModel.profile,
                size: 96,
                showsEditBadge: true,
                onEdit: onEditPersonalInfo
            )

            Text(viewModel.profile.name)
                .font(.system(size: AppTheme.Profile.cardTitleSize + 2, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            if !viewModel.profile.profileHeaderSubtitle.isEmpty {
                Text(viewModel.profile.profileHeaderSubtitle)
                    .font(.system(size: AppTheme.Profile.cardSubtitleSize))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            if !viewModel.profile.currentCity.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: AppTheme.Profile.detailLabelSize))
                    Text(viewModel.profile.currentCity)
                        .font(.system(size: AppTheme.Profile.cardSubtitleSize))
                }
                .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var basicInformationSection: some View {
        ProfileSectionGroup(title: Strings.Profile.basicInformation, onEdit: onEditPersonalInfo) {
            VStack(alignment: .leading, spacing: 16) {
                ProfileIconDetailRow(
                    icon: "person",
                    label: Strings.Profile.fullName,
                    value: viewModel.profile.name
                )
                ProfileIconDetailRow(
                    icon: "calendar",
                    label: Strings.Profile.age,
                    value: viewModel.profile.age.map { "\($0) years" } ?? ""
                )
                ProfileIconDetailRow(
                    icon: "face.smiling",
                    label: Strings.Profile.gender,
                    value: viewModel.profile.gender?.displayName ?? ""
                )
                ProfileIconDetailRow(
                    icon: "briefcase",
                    label: Strings.Profile.profession,
                    value: viewModel.profile.professionDisplay
                )
                ProfileIconDetailRow(
                    icon: "mappin.and.ellipse",
                    label: Strings.Profile.currentCity,
                    value: viewModel.profile.currentCity
                )
            }
        }
    }

    private var contactSection: some View {
        ProfileSectionGroup(title: Strings.Profile.contactAndPrivacy, onEdit: onEditContact) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    ProfileIconDetailRow(
                        icon: "envelope",
                        label: Strings.Profile.email,
                        value: viewModel.profile.email
                    )

                    if viewModel.profile.isEmailVerified {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.availableGreen)
                            .padding(.top, 14)
                    }
                }

                if let linkedIn = viewModel.profile.linkedInLink {
                    ProfileIconDetailRow(
                        icon: "link",
                        label: "LinkedIn",
                        value: linkedIn.link,
                        isLink: true
                    )
                } else {
                    ForEach(viewModel.profile.socialLinks.filter { !$0.link.isEmpty }) { link in
                        ProfileIconDetailRow(
                            icon: link.type.systemImage,
                            label: link.type.displayName,
                            value: link.link,
                            isLink: true
                        )
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        ProfileSectionGroup(title: Strings.Profile.aboutYou, onEdit: onEditAboutMe) {
            VStack(alignment: .leading, spacing: 16) {
                Text(
                    viewModel.profile.about.isEmpty
                        ? Strings.Profile.aboutEmpty
                        : viewModel.profile.about
                )
                .font(.system(size: AppTheme.Profile.cardSubtitleSize))
                .foregroundStyle(
                    viewModel.profile.about.isEmpty
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                if !viewModel.profile.lifestyleNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(Strings.Profile.lifestyleNotes)
                            .font(.system(size: AppTheme.Profile.detailLabelSize))
                            .foregroundStyle(AppTheme.textSecondary)
                        WrapChips(items: viewModel.profile.lifestyleNotes)
                    }
                }
            }
        }
    }

    private var listingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Strings.Profile.listing)
                .font(.system(size: AppTheme.Profile.sectionTitleSize, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            if viewModel.isLoadingListings && viewModel.listings.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(Strings.Common.loading)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else if viewModel.listings.isEmpty {
                emptyListingCard
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.listings) { listing in
                        ProfileListingCard(
                            listing: listing,
                            onEdit: { onEditListing(listing.post) },
                            onDelete: { listingPendingDeletion = listing }
                        )
                    }
                }
            }
        }
    }

    private var emptyListingCard: some View {
        VStack(spacing: 20) {
            Text(Strings.Profile.noListingYet)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            ProfileAddPostButton(action: onAddPost)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
