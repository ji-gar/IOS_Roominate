import SwiftUI

struct ChatDetailsSheet: View {
    let details: ChatPostDetails
    let isShortlisting: Bool
    let isShortlisted: Bool
    let onShortlist: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroImage
                    titleSection
                    infoRows
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            shortlistBar
        }
        .background(Color.white.ignoresSafeArea())
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Text("Details")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Divider() }
    }

    @ViewBuilder
    private var heroImage: some View {
        if let imageURL = details.imageURL {
            RemoteImage(urlString: imageURL, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))
        } else {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "#E5E7EB"))
                .frame(height: 200)
                .overlay {
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundStyle(Color(hex: "#9EA3B0"))
                }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(details.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))

            if !details.location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "#6B7280"))
                    Text(details.location)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#6B7280"))
                }
            }
        }
    }

    private var infoRows: some View {
        VStack(spacing: 14) {
            detailRow(label: "Looking for", value: details.lookingFor)
            detailRow(label: "Deposit", value: details.deposit)
            detailRow(label: "Rent", value: details.rent)
            detailRow(label: "Move in date", value: details.moveInDate)
            detailRow(label: "Extra", value: details.extras)
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "#6B7280"))
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "#1A1A2E"))
            Spacer()
        }
    }

    private var shortlistBar: some View {
        HStack {
            Spacer()
            Button(action: onShortlist) {
                HStack(spacing: 8) {
                    if isShortlisting {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                    }
                    Text(isShortlisted ? "Shortlisted" : "Shortlist")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .frame(height: 44)
                .background(isShortlisted ? Color(hex: "#6B7280") : AppTheme.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(isShortlisting || isShortlisted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(alignment: .top) { Divider() }
    }
}

struct BlockUserConfirmationDialog: View {
    let isBlocking: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 16) {
                Text("Block User")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "#1A1A2E"))

                Text("Are you sure you want to Block this user?")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "#6B7280"))
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(hex: "#1A1A2E"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "#E5E7EB"), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isBlocking)

                    Button(action: onConfirm) {
                        Group {
                            if isBlocking {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Block")
                            }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppTheme.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .disabled(isBlocking)
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 32)
        }
    }
}
