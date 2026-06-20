import SwiftUI

// MARK: - Bottom Navigation Bar

struct CreatePostBottomBar: View {
    let currentStep: Int
    let totalSteps: Int
    let backLabel: String
    let nextLabel: String
    let isNextEnabled: Bool
    let isNextLoading: Bool
    let onBack: () -> Void
    let onNext: () -> Void

    init(
        currentStep: Int,
        totalSteps: Int,
        backLabel: String = "Back",
        nextLabel: String = "Next",
        isNextEnabled: Bool = true,
        isNextLoading: Bool = false,
        onBack: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.backLabel = backLabel
        self.nextLabel = nextLabel
        self.isNextEnabled = isNextEnabled
        self.isNextLoading = isNextLoading
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        VStack(spacing: 0) {
            progressBar
            Divider()
            navButtons
        }
        .background(Color.white)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(AppTheme.fieldBorder)
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(AppTheme.primaryBlue)
                        .frame(width: geo.size.width * CGFloat(currentStep) / CGFloat(totalSteps))
                    Spacer(minLength: 0)
                }
                .animation(.easeInOut(duration: 0.35), value: currentStep)
            }
        }
        .frame(height: 3)
    }

    private var navButtons: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .medium))
                    Text(backLabel)
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(AppTheme.textPrimary)
            }

            Spacer()

            Button(action: onNext) {
                Group {
                    if isNextLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(0.85)
                            .frame(width: 20, height: 20)
                    } else {
                        HStack(spacing: 5) {
                            Text(nextLabel)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .medium))
                        }
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isNextEnabled ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 22)
                .frame(height: 44)
                .background(
                    isNextEnabled
                    ? AppTheme.primaryBlue
                    : Color(red: 0.91, green: 0.92, blue: 0.94)
                )
                .clipShape(Capsule())
                .animation(.easeInOut(duration: 0.2), value: isNextEnabled)
            }
            .disabled(!isNextEnabled || isNextLoading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

// MARK: - Page Dots Indicator

struct CreatePostPageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? AppTheme.primaryBlue : AppTheme.fieldBorder)
                    .frame(width: index == current ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: current)
            }
        }
    }
}

// MARK: - Option Chip (Property Type / Furnishing)

struct PostOptionChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(
                    isSelected
                    ? AppTheme.textPrimary
                    : Color.white
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.clear : AppTheme.fieldBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Segmented Space Type Picker

struct PostSpaceTypePicker: View {
    let options: [String]
    @Binding var selected: String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = option
                    }
                } label: {
                    Text(option)
                        .font(.system(size: 14, weight: selected == option ? .semibold : .regular))
                        .foregroundStyle(
                            selected == option ? AppTheme.textPrimary : AppTheme.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            selected == option
                            ? Color.white
                            : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .shadow(
                            color: selected == option ? Color.black.opacity(0.06) : .clear,
                            radius: 4, x: 0, y: 2
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(AppTheme.segmentTrack)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }
}

// MARK: - Amenity Chip

struct AmenityChipView: View {
    let amenity: AmenityItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: amenity.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.white : AppTheme.textPrimary)
                    .frame(height: 22)

                Text(amenity.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? Color.white : AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                ? AppTheme.textPrimary
                : Color.white
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : AppTheme.fieldBorder, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Outlined Text Field with Floating Label

struct OutlinedInputField: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    private var isFilled: Bool { !text.isEmpty }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isFilled ? AppTheme.primaryBlue.opacity(0.45) : AppTheme.fieldBorder, lineWidth: 1)

            VStack(alignment: .leading, spacing: 2) {
                // Floating label — always occupies space; visibility via opacity
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryBlue)
                    .opacity(isFilled ? 1 : 0)

                // Single stable TextField so focus isn't lost on first keystroke
                TextField(label, text: $text)
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.textPrimary)
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
        }
        .frame(height: 60)
        .animation(.easeInOut(duration: 0.18), value: isFilled)
    }
}

// MARK: - Section Header for Form

struct CreatePostSectionLabel: View {
    let title: String
    var isRequired: Bool = true

    var body: some View {
        HStack(spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
            if isRequired {
                Text("*")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.errorRed)
            }
        }
    }
}

// MARK: - Currency Input Field

struct CreatePostCurrencyField: View {
    @Binding var amount: String
    var placeholder: String = "0"

    private var isFilled: Bool { !amount.isEmpty }

    var body: some View {
        HStack(spacing: 8) {
            Text("₹")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isFilled ? AppTheme.textPrimary : AppTheme.textSecondary)

            TextField(placeholder, text: $amount)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .keyboardType(.numberPad)
                .onChange(of: amount) { _, newValue in
                    let digits = newValue.filter(\.isNumber)
                    if digits != newValue { amount = digits }
                }
        }
        .padding(.horizontal, 14)
        .frame(height: 54)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFilled ? AppTheme.primaryBlue.opacity(0.5) : AppTheme.fieldBorder, lineWidth: 1)
        )
    }
}

// MARK: - Date Selection Field (presents a date picker dialog)

struct CreatePostDateField: View {
    let placeholder: String
    let displayValue: String
    @Binding var date: Date?
    var minimumDate: Date? = nil

    @State private var showPicker = false
    @State private var tempDate = Date()

    private var isFilled: Bool { !displayValue.isEmpty }

    var body: some View {
        Button {
            tempDate = date ?? max(minimumDate ?? Date(), Date())
            showPicker = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 15))
                    .foregroundStyle(isFilled ? AppTheme.primaryBlue : AppTheme.textSecondary)

                Text(isFilled ? displayValue : placeholder)
                    .font(.system(size: 15, weight: isFilled ? .medium : .regular))
                    .foregroundStyle(isFilled ? AppTheme.textPrimary : AppTheme.textSecondary)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFilled ? AppTheme.primaryBlue.opacity(0.5) : AppTheme.fieldBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            datePickerSheet
        }
    }

    private var datePickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { showPicker = false }
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Text(placeholder)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button("Update") {
                    date = tempDate
                    showPicker = false
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.primaryBlue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            DatePicker(
                "",
                selection: $tempDate,
                in: (minimumDate ?? Date.distantPast)...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(AppTheme.primaryBlue)
            .padding(.horizontal, 12)

            Spacer()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Icon Choice Chip (Preferences)

struct IconChoiceChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color.white : AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isSelected ? AppTheme.textPrimary : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : AppTheme.fieldBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Toggle Row (e.g. Looking for long term)

struct CreatePostToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.primaryBlue)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.fieldBorder, lineWidth: 1)
        )
    }
}

// MARK: - Create Post Illustration (Step Intro)

struct CreatePostIllustration: View {
    let systemImage: String
    let tint: Color
    let bgColor: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(bgColor)

            Circle()
                .fill(Color.white.opacity(0.45))
                .frame(width: 160, height: 160)
                .offset(x: -90, y: 55)

            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 100, height: 100)
                .offset(x: 100, y: -50)

            Image(systemName: systemImage)
                .font(.system(size: 88))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(tint)
                .shadow(color: tint.opacity(0.3), radius: 16, x: 0, y: 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }
}
