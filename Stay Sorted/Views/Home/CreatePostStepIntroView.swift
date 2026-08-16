import SwiftUI

/// Intro screen shown before each major step of the create-post flow
/// (e.g. "Home & Amenities", "Get Availability & Rent", "Add Location & Photos").
struct CreatePostStepIntroView: View {
    let stepIndex: Int          // zero-based index of the step (0, 1, 2)
    let totalSteps: Int
    let stepLabel: String       // e.g. "Step 1"
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let bgColor: Color
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    CreatePostIllustration(
                        systemImage: systemImage,
                        tint: tint,
                        bgColor: bgColor
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 36)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(stepLabel)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(subtitle)
                            .font(.system(size: 15))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }

            VStack(spacing: 0) {
                CreatePostPageDots(count: totalSteps, current: stepIndex)
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
