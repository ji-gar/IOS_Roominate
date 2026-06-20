import SwiftUI

struct CreatePostSeekerBudgetView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Describe Your Ideal\nLiving Space")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Enter Budget")
                        CreatePostCurrencyField(amount: $viewModel.draft.monthlyRent, placeholder: "10,000")
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        CreatePostSectionLabel(title: "Move-in Date")

                        moveInOption(
                            title: "Immediately",
                            isSelected: viewModel.moveInImmediately
                        ) {
                            viewModel.moveInImmediately = true
                        }

                        moveInOption(
                            title: "Looking for specific date",
                            isSelected: !viewModel.moveInImmediately
                        ) {
                            viewModel.moveInImmediately = false
                        }

                        if !viewModel.moveInImmediately {
                            CreatePostDateField(
                                placeholder: "DD/MM/YY",
                                displayValue: viewModel.displayDate(for: viewModel.draft.availableFrom),
                                date: $viewModel.availableFromDate
                            )
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .animation(.easeInOut(duration: 0.2), value: viewModel.moveInImmediately)
            }

            CreatePostBottomBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                isNextEnabled: viewModel.isSeekerBudgetValid,
                onBack: onBack,
                onNext: onNext
            )
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Create Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { createPostBackToolbar(action: onBack) }
        .onAppear {
            if viewModel.moveInImmediately, viewModel.availableFromDate == nil {
                viewModel.availableFromDate = Date()
            }
        }
    }

    private func moveInOption(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.primaryBlue : AppTheme.fieldBorder, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(AppTheme.primaryBlue)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
