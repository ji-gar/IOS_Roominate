import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    let onFinished: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image("SplashLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.5, 300))
                        .padding(.horizontal, 40)

                    Text(Strings.Splash.title)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryBlue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                viewModel.start()
            }
            .onChange(of: viewModel.isActive) { _, isActive in
                if isActive {
                    onFinished()
                }
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
