import SwiftUI

struct CreatePostOverviewView: View {
    let onStart: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    stepRow(
                        number: 1,
                        title: "Home & Amenities",
                        description: "Tell us about your place — number of rooms, type of furnishing, and included amenities.",
                        systemImage: "sofa.fill",
                        iconColor: Color(red: 0.91, green: 0.68, blue: 0.22),
                        iconBg: Color(red: 0.97, green: 0.93, blue: 0.83)
                    )

                    separator

                    stepRow(
                        number: 2,
                        title: "Availability & Price",
                        description: "Let others know when the place is available and how much the rent is.",
                        systemImage: "calendar.badge.clock",
                        iconColor: Color(red: 0.20, green: 0.53, blue: 0.96),
                        iconBg: Color(red: 0.86, green: 0.92, blue: 0.99)
                    )

                    separator

                    stepRow(
                        number: 3,
                        title: "Location & Photos",
                        description: "Share the location and upload clear photos to help others picture the space.",
                        systemImage: "house.fill",
                        iconColor: Color(red: 0.82, green: 0.38, blue: 0.22),
                        iconBg: Color(red: 0.99, green: 0.90, blue: 0.86)
                    )
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            bottomBar
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

    // MARK: - Step Row

    private func stepRow(
        number: Int,
        title: String,
        description: String,
        systemImage: String,
        iconColor: Color,
        iconBg: Color
    ) -> some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(number) \(title)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(iconBg)

                Image(systemName: systemImage)
                    .font(.system(size: 38))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(iconColor)
            }
            .frame(width: 82, height: 82)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 26)
    }

    private var separator: some View {
        Divider()
            .padding(.horizontal, 20)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            PrimaryButton(title: "Create Post", isEnabled: true, action: onStart)
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}

