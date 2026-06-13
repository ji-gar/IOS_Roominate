import SwiftUI

/// Bordered card showing an icon, a small caption and a bold value.
/// Used in the detail screens' attribute grids.
struct InfoCard: View {
    let icon: String
    let caption: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.iconTint)
                .frame(width: 20)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(caption)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textSecondary)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.infoCardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Two info cards in a row, used to build attribute grids.
struct InfoCardRow: View {
    let left: InfoCard
    let right: InfoCard

    var body: some View {
        HStack(spacing: 12) {
            left
            right
        }
    }
}

/// Section heading used on detail screens (e.g. "Financial Details").
struct DetailSectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(AppTheme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Flowing wrap layout for chips/tags.
struct WrapChips: View {
    let items: [String]

    var body: some View {
        FlexibleWrap(items: items, spacing: 8, lineSpacing: 8) { item in
            TagChip(text: item)
        }
    }
}

/// A simple flow layout that wraps content onto multiple lines.
struct FlexibleWrap<Content: View>: View {
    let items: [String]
    let spacing: CGFloat
    let lineSpacing: CGFloat
    let content: (String) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                content(item)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height + lineSpacing
                        }
                        let result = width
                        if item == items.last {
                            width = 0
                        } else {
                            width -= dimension.width + spacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(heightReader)
    }

    private var heightReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { totalHeight = proxy.size.height }
                .onChange(of: proxy.size.height) { _, newValue in totalHeight = newValue }
        }
    }
}
