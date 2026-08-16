import SwiftUI

// MARK: - Section header

/// Uppercase grey caption used to title each filter section.
struct FilterSectionHeader: View {
    let title: String
    var trailing: AnyView?

    init(_ title: String, trailing: AnyView? = nil) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .tracking(0.5)
            Spacer()
            if let trailing {
                trailing
            }
        }
    }
}

// MARK: - Selectable chip

/// Rounded pill used for City / Property type / Amenities selection.
struct FilterChip: View {
    let title: String
    var systemImage: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary)
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(isSelected ? AppTheme.primaryBlue.opacity(0.10) : Color.white)
            .overlay(
                Capsule()
                    .stroke(isSelected ? AppTheme.primaryBlue : AppTheme.infoCardBorder,
                            lineWidth: isSelected ? 1.5 : 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow layout

/// A wrapping flow layout (leading aligned) used for chip groups.
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    var lineSpacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rows = computeRows(maxWidth: maxWidth, subviews: subviews)
        let height = rows.last.map { $0.yOffset + $0.height } ?? 0
        rows.removeAll()
        return CGSize(width: maxWidth == .infinity ? 0 : maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        for row in rows {
            for element in row.elements {
                let size = subviews[element.index].sizeThatFits(.unspecified)
                subviews[element.index].place(
                    at: CGPoint(x: bounds.minX + element.xOffset, y: bounds.minY + row.yOffset),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(size)
                )
            }
        }
    }

    private struct Row {
        var elements: [(index: Int, xOffset: CGFloat)] = []
        var yOffset: CGFloat = 0
        var height: CGFloat = 0
    }

    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        var y: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            if x + size.width > maxWidth, !currentRow.elements.isEmpty {
                currentRow.yOffset = y
                rows.append(currentRow)
                y += currentRow.height + lineSpacing
                currentRow = Row()
                x = 0
            }
            currentRow.elements.append((index: index, xOffset: x))
            currentRow.height = max(currentRow.height, size.height)
            x += size.width + spacing
        }

        if !currentRow.elements.isEmpty {
            currentRow.yOffset = y
            rows.append(currentRow)
        }
        return rows
    }
}

// MARK: - Range slider

/// Dual-handle range slider for the monthly rent section.
struct RentRangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let bounds: ClosedRange<Double>
    let step: Double

    private let trackHeight: CGFloat = 4
    private let handleSize: CGFloat = 26

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let usableWidth = max(width - handleSize, 1)
            let lowerX = position(for: lowerValue, in: usableWidth)
            let upperX = position(for: upperValue, in: usableWidth)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.segmentTrack)
                    .frame(height: trackHeight)

                Capsule()
                    .fill(AppTheme.primaryBlue)
                    .frame(width: max(upperX - lowerX, 0), height: trackHeight)
                    .offset(x: lowerX + handleSize / 2)

                handle
                    .offset(x: lowerX)
                    .gesture(dragGesture(isLower: true, usableWidth: usableWidth))

                handle
                    .offset(x: upperX)
                    .gesture(dragGesture(isLower: false, usableWidth: usableWidth))
            }
            .frame(height: handleSize)
            .frame(maxHeight: .infinity)
        }
        .frame(height: handleSize)
    }

    private var handle: some View {
        Circle()
            .fill(Color.white)
            .frame(width: handleSize, height: handleSize)
            .overlay(Circle().stroke(AppTheme.primaryBlue, lineWidth: 3))
            .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
    }

    private func position(for value: Double, in usableWidth: CGFloat) -> CGFloat {
        let ratio = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return CGFloat(ratio) * usableWidth
    }

    private func value(for x: CGFloat, in usableWidth: CGFloat) -> Double {
        let ratio = Double(max(0, min(x, usableWidth)) / usableWidth)
        let raw = bounds.lowerBound + ratio * (bounds.upperBound - bounds.lowerBound)
        let stepped = (raw / step).rounded() * step
        return min(max(stepped, bounds.lowerBound), bounds.upperBound)
    }

    private func dragGesture(isLower: Bool, usableWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                let newValue = value(for: gesture.location.x - handleSize / 2, in: usableWidth)
                if isLower {
                    lowerValue = min(newValue, upperValue - step)
                } else {
                    upperValue = max(newValue, lowerValue + step)
                }
            }
    }
}

// MARK: - Room type card

struct RoomTypeCard: View {
    let roomType: ListingFilters.RoomType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: roomType.systemImage)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(roomType.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(roomType.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(isSelected ? AppTheme.primaryBlue.opacity(0.08) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.primaryBlue : AppTheme.infoCardBorder,
                            lineWidth: isSelected ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Furnishing toggle row

struct FurnishingToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryBlue))
    }
}

// MARK: - Date field

struct MoveInDateField: View {
    let caption: String
    @Binding var date: Date?

    @State private var showPicker = false
    @State private var tempDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(caption.uppercased())
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
            Button {
                tempDate = date ?? Date()
                showPicker = true
            } label: {
                HStack {
                    Text(date.map { DateFormatterHelper.displayDate(from: $0) } ?? "Select")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(date == nil ? AppTheme.textSecondary : AppTheme.textPrimary)
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.iconTint)
                }
                .padding(.horizontal, 12)
                .frame(height: 46)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.infoCardBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showPicker) {
            datePickerSheet
        }
    }

    private var datePickerSheet: some View {
        VStack(spacing: 16) {
            DatePicker(
                caption,
                selection: $tempDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(AppTheme.primaryBlue)
            .padding(.horizontal)

            PrimaryButton(title: "Done") {
                date = tempDate
                showPicker = false
            }
            .padding(.horizontal)
        }
        .padding(.top, 24)
        .presentationDetents([.medium, .large])
    }
}
