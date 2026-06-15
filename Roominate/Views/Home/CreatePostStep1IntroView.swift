import SwiftUI

struct CreatePostStep1IntroView: View {
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Illustration
                    CreatePostIllustration(
                        systemImage: "sofa.fill",
                        tint: Color(red: 0.91, green: 0.68, blue: 0.22),
                        bgColor: Color(red: 0.96, green: 0.92, blue: 0.84)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 36)

                    // Text content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 1")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        Text("Home & Amenities")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Tell us about your place — number of rooms, type of furnishing, and included amenities.")
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }

            // Bottom: dots + nav
            VStack(spacing: 0) {
                CreatePostPageDots(count: 4, current: 0)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)

                Divider()

                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .medium))
                            Text("Back")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundStyle(AppTheme.textPrimary)
                    }

                    Spacer()

                    Button(action: onNext) {
                        HStack(spacing: 5) {
                            Text("Next")
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 44)
                        .background(AppTheme.primaryBlue)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .background(Color.white)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Create Post")
                            .font(.system(size: 16))
                    }
                    .foregroundStyle(AppTheme.primaryBlue)
                }
            }
        }
    }
}
