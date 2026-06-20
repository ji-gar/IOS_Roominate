import SwiftUI

struct CreatePostAvailabilityView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onNext: () -> Void

    private var lookingForShortTerm: Binding<Bool> {
        Binding(
            get: { !viewModel.draft.lookingForLongTerm },
            set: { viewModel.draft.lookingForLongTerm = !$0 }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Monthly Rent")
                        CreatePostCurrencyField(amount: $viewModel.draft.monthlyRent, placeholder: "5,000")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Deposit")
                        CreatePostCurrencyField(amount: $viewModel.draft.deposit, placeholder: "2,000")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Extra Cost")
                        OutlinedInputField(label: "Extra Cost", text: $viewModel.draft.extraCost)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        CreatePostSectionLabel(title: "Available From")
                        CreatePostDateField(
                            placeholder: "DD/MM/YY",
                            displayValue: viewModel.displayDate(for: viewModel.draft.availableFrom),
                            date: $viewModel.availableFromDate
                        )
                    }

                    Button {
                        lookingForShortTerm.wrappedValue.toggle()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: lookingForShortTerm.wrappedValue ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundStyle(
                                    lookingForShortTerm.wrappedValue
                                    ? AppTheme.primaryBlue
                                    : AppTheme.fieldBorder
                                )

                            Text("Looking for Short-term")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)

                    if lookingForShortTerm.wrappedValue {
                        VStack(alignment: .leading, spacing: 10) {
                            CreatePostSectionLabel(title: "Available Till")
                            CreatePostDateField(
                                placeholder: "DD/MM/YY",
                                displayValue: viewModel.displayDate(for: viewModel.draft.availableTo),
                                date: $viewModel.availableToDate,
                                minimumDate: viewModel.availableFromDate
                            )
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .animation(.easeInOut(duration: 0.2), value: lookingForShortTerm.wrappedValue)
            }

            CreatePostBottomBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                isNextEnabled: viewModel.isAvailabilityValid,
                onBack: onBack,
                onNext: onNext
            )
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
