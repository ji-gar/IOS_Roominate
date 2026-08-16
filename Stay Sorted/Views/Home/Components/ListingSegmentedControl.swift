import SwiftUI

/// Custom pill segmented control matching the Home design (Flat / Flat-mate).
struct ListingSegmentedControl: View {
    @Binding var selection: ListingSegment
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ListingSegment.allCases) { segment in
                segmentButton(segment)
            }
        }
        .padding(4)
        .background(AppTheme.segmentTrack)
        .clipShape(Capsule())
    }

    private func segmentButton(_ segment: ListingSegment) -> some View {
        let isSelected = selection == segment
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selection = segment
            }
        } label: {
            Text(segment.rawValue)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Color.white)
                            .matchedGeometryEffect(id: "segment", in: animation)
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
