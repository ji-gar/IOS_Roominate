import SwiftUI

struct ProfileFormTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var isRequired: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isRequired {
                RequiredLabel(title: title)
            } else {
                Text(title)
                    .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
            }

            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: AppTheme.Profile.fieldInputSize))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                TextField(placeholder.isEmpty ? title : placeholder, text: $text)
                    .font(.system(size: AppTheme.Profile.fieldInputSize))
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
                    .appTextInputStyle()
            }
            .padding(.horizontal, 16)
            .frame(height: AppTheme.Profile.fieldHeight)
            .background(AppTheme.fieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.fieldBorder, lineWidth: 1)
            )
        }
    }
}

struct ProfileMenuRow: View {
    let title: String
    let systemImage: String
    var showsChevron = false
    var isDestructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: AppTheme.Profile.menuIconSize, weight: .regular))
                    .foregroundStyle(isDestructive ? AppTheme.errorRed : AppTheme.textPrimary)
                    .frame(width: 24, alignment: .center)

                Text(title)
                    .font(.system(size: AppTheme.Profile.menuTitleSize, weight: .regular))
                    .foregroundStyle(isDestructive ? AppTheme.errorRed : AppTheme.textPrimary)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(showsChevron ? AppTheme.textSecondary.opacity(0.45) : .clear)
            }
            .padding(.horizontal, 16)
            .frame(height: AppTheme.Profile.menuRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Inset hairline divider — used between rows and between sections.
struct ProfileMenuItemDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(red: 0.90, green: 0.91, blue: 0.93))
            .frame(height: 1 / UIScreen.main.scale)
            .padding(.leading, 50)
    }
}

/// Full-width divider — used between menu sections to create visual groupings.
struct ProfileMenuSectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(red: 0.87, green: 0.88, blue: 0.90))
            .frame(height: 1)
    }
}

struct ProfileMenuSection: View {
    let rows: [ProfileMenuItem]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    ProfileMenuItemDivider()
                }
                ProfileMenuRow(
                    title: item.title,
                    systemImage: item.systemImage,
                    showsChevron: item.showsChevron,
                    isDestructive: item.isDestructive,
                    action: item.action
                )
            }
        }
    }
}

struct ProfileMenuItem {
    let title: String
    let systemImage: String
    var showsChevron = false
    var isDestructive = false
    var action: () -> Void = {}
}

struct ProfileSectionEditButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "pencil")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 36, height: 36)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ProfileSectionGroup<Content: View>: View {
    let title: String
    var onEdit: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: AppTheme.Profile.sectionTitleSize, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                if let onEdit {
                    ProfileSectionEditButton(action: onEdit)
                }
            }

            content()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct ProfileSectionCard<Content: View>: View {
    let title: String
    var onEdit: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        ProfileSectionGroup(title: title, onEdit: onEdit, content: content)
    }
}

struct ProfileIconDetailRow: View {
    let icon: String
    let label: String
    let value: String
    var trailing: AnyView? = nil
    var isLink: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: AppTheme.Profile.detailLabelSize))
                    .foregroundStyle(AppTheme.textSecondary)

                HStack(spacing: 8) {
                    valueView
                    if let trailing {
                        trailing
                    }
                }
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var valueView: some View {
        if isLink, !value.isEmpty {
            if let url = linkURL(from: value) {
                Link(destination: url) {
                    Text(displayLink(value))
                        .font(.system(size: AppTheme.Profile.detailValueSize))
                        .foregroundStyle(AppTheme.primaryBlue)
                        .underline()
                }
            } else {
                Text(value)
                    .font(.system(size: AppTheme.Profile.detailValueSize))
                    .foregroundStyle(AppTheme.primaryBlue)
                    .underline()
            }
        } else {
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: AppTheme.Profile.detailValueSize))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    private func displayLink(_ value: String) -> String {
        value
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
    }

    private func linkURL(from value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return URL(string: trimmed)
        }
        return URL(string: "https://\(trimmed)")
    }
}

struct ProfileDetailRow: View {
    let label: String
    let value: String
    var trailing: AnyView? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: AppTheme.Profile.detailLabelSize))
                .foregroundStyle(AppTheme.textSecondary)
            HStack(spacing: 8) {
                Text(value.isEmpty ? "—" : value)
                    .font(.system(size: AppTheme.Profile.detailValueSize, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                if let trailing {
                    trailing
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProfileAvatarView: View {
    let profile: UserProfile
    var size: CGFloat = 72
    var style: ProfileAvatarStyle = .standard
    var showsEditBadge: Bool = false
    var onEdit: (() -> Void)? = nil

    enum ProfileAvatarStyle {
        case standard
        case settings
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: size, height: size)

                if let data = profile.profileImageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else if let url = profile.profileImageURL {
                    AvatarView(urlString: url, size: size, fallbackInitials: profile.initials, style: style)
                } else if !profile.initials.isEmpty {
                    Text(profile.initials.prefix(1))
                        .font(.system(size: size * 0.38, weight: .medium))
                        .foregroundStyle(initialsColor)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.38))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            if showsEditBadge {
                Button(action: { onEdit?() }) {
                    Circle()
                        .fill(AppTheme.primaryBlue)
                        .frame(width: size * 0.32, height: size * 0.32)
                        .overlay {
                            Image(systemName: "pencil")
                                .font(.system(size: size * 0.13, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                }
                .buttonStyle(.plain)
                .offset(x: 2, y: 2)
            }
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .standard:
            return Color(red: 0.88, green: 0.93, blue: 0.98)
        case .settings:
            return Color(red: 0.90, green: 0.91, blue: 0.93)
        }
    }

    private var initialsColor: Color {
        switch style {
        case .standard:
            return AppTheme.primaryBlue
        case .settings:
            return AppTheme.textPrimary
        }
    }
}

struct ProfileListingActionButton: View {
    let title: String
    var isDestructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .medium))
                .foregroundStyle(isDestructive ? AppTheme.errorRed : AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.buttonHeight)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ProfileAddPostButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                Text(Strings.Profile.addPost)
                    .font(.system(size: AppTheme.Profile.fieldLabelSize, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.buttonHeight)
            .background(AppTheme.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

struct ProfileListingCard: View {
    let listing: UserListing
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var currentImage = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let flat = listing.flatListing {
                flatContent(flat)
            } else if let flatmate = listing.flatmateListing {
                flatmateContent(flatmate)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private func flatContent(_ listing: FlatListing) -> some View {
        listingImage(urls: listing.imageURLs)
        listingTitle(listing.title)
        listingLocation(listing.location)
        listingDetails(
            lookingFor: listing.lookingFor,
            deposit: listing.deposit,
            rent: listing.rent,
            subtitle: "\(listing.roomType) - Move In \(listing.moveInDate)",
            amenities: listing.amenities
        )
        actionButtons
    }

    @ViewBuilder
    private func flatmateContent(_ listing: FlatmateListing) -> some View {
        listingTitle(listing.title)
        listingLocation(listing.location)
        listingDetails(
            lookingFor: listing.lookingFor,
            deposit: listing.maxBudget,
            rent: listing.maxBudgetMonthly,
            subtitle: "\(listing.roomType) - From \(listing.fromDate)",
            amenities: listing.tags.joined(separator: ", ")
        )
        actionButtons
    }

    private func listingImage(urls: [String]) -> some View {
        ZStack(alignment: .topTrailing) {
            if urls.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.chipBackground)
                    .frame(height: 190)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
            } else {
                TabView(selection: $currentImage) {
                    ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                        RemoteImage(urlString: url)
                            .frame(maxWidth: .infinity)
                            .frame(height: 190)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: urls.count > 1 ? .automatic : .never))
                .frame(height: 190)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func listingTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(AppTheme.textPrimary)
    }

    private func listingLocation(_ location: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.textSecondary)
            Text(location)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private func listingDetails(
        lookingFor: String,
        deposit: String,
        rent: String,
        subtitle: String,
        amenities: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            InlineDetail(label: "Looking for", value: lookingFor)
            InlineDetail(label: "Deposit", value: deposit, valueIsBold: false)
            InlineDetail(label: "Rent", value: rent, valueIsBold: false)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
            if !amenities.isEmpty {
                Text(amenities)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            ProfileListingActionButton(title: Strings.Profile.editListing, action: onEdit)
            ProfileListingActionButton(title: Strings.Profile.deleteListing, isDestructive: true, action: onDelete)
        }
        .padding(.top, 4)
    }
}

@ViewBuilder
func profileEditContainer<Content: View>(
    title: String,
    onBack: @escaping () -> Void,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(spacing: 0) {
        HStack {
            BackButton(action: onBack)
            Spacer()
            Text(title)
                .font(.system(size: AppTheme.Profile.sectionTitleSize, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppTheme.horizontalPadding)
        .frame(minHeight: 44)

        ScrollView {
            content()
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.top, 24)
                .padding(.bottom, 32)
        }
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarHidden(true)
}
