import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 16) {
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text(Strings.Splash.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryBlue)
            }
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

#Preview {
    SplashView(onFinished: {})
}
