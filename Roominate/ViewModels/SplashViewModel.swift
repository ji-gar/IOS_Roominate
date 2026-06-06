import Combine
import Foundation

@MainActor
final class SplashViewModel: ObservableObject {
    @Published var isActive = false

    func start() {
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            isActive = true
        }
    }
}
