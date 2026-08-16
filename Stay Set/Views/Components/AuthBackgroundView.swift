import SwiftUI

struct AuthBackgroundView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Circle()
                .fill(AppTheme.primaryBlue.opacity(0.08))
                .frame(width: 320, height: 320)
                .offset(x: -140, y: -280)

            Circle()
                .stroke(AppTheme.primaryBlue.opacity(0.06), lineWidth: 1.5)
                .frame(width: 420, height: 420)
                .offset(x: 120, y: 320)

            Path { path in
                path.move(to: CGPoint(x: 0, y: 500))
                path.addLine(to: CGPoint(x: 180, y: 380))
                path.addLine(to: CGPoint(x: 400, y: 520))
            }
            .stroke(AppTheme.primaryBlue.opacity(0.05), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}
