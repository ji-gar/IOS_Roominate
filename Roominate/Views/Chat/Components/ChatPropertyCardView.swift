import SwiftUI

struct ChatPropertyCardView: View {
    let details: ChatPostDetails
    let onViewDetails: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(details.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .multilineTextAlignment(.leading)

                Button(action: onViewDetails) {
                    Text("View Details")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryBlue)
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(hex: "#F1F2F4"))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .frame(maxWidth: 280, alignment: .leading)
    }
}
