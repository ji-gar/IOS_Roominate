import Combine
import Foundation

enum OTPFlowType {
    case signUpVerification
    case signIn

    var title: String {
        switch self {
        case .signUpVerification: return Strings.OTP.enterCodeTitle
        case .signIn: return Strings.OTP.enterOTPTitle
        }
    }

    var subtitle: String {
        switch self {
        case .signUpVerification: return Strings.OTP.enterCodeSubtitle
        case .signIn: return Strings.OTP.enterOTPSubtitle
        }
    }

    var actionTitle: String {
        switch self {
        case .signUpVerification: return Strings.OTP.verifyButton
        case .signIn: return Strings.OTP.signInButton
        }
    }
}

@MainActor
final class OTPViewModel: ObservableObject {
    @Published var code = ""
    @Published var remainingSeconds = 34
    @Published var isLoading = false
    @Published var errorMessage: String?

    let flowType: OTPFlowType
    let email: String
    let password: String?
    private let authService: AuthServiceProtocol
    private var timerTask: Task<Void, Never>?

    private let codeLength = 4

    init(
        flowType: OTPFlowType,
        email: String,
        password: String? = nil,
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.flowType = flowType
        self.email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.password = password
        self.authService = authService
        startTimer()
    }

    deinit {
        timerTask?.cancel()
    }

    var isComplete: Bool {
        code.count == codeLength
    }

    var canResend: Bool {
        remainingSeconds <= 0
    }

    var formattedTimer: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func appendDigit(_ digit: String) {
        guard code.count < codeLength else { return }
        code += digit
    }

    func deleteDigit() {
        guard !code.isEmpty else { return }
        code.removeLast()
    }

    func verify() async -> OTPResult {
        guard isComplete else { return .failure }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            switch flowType {
            case .signUpVerification:
                _ = try await authService.verifyOTP(email: email, otp: code)
                if let password {
                    _ = try await authService.login(email: email, password: password)
                }
                let isComplete = try await authService.resolveProfileCompletion()
                return isComplete ? .authenticatedComplete : .authenticatedNeedsProfile

            case .signIn:
                return try await completeSignInWithOTP()
            }
        } catch {
            errorMessage = error.localizedDescription
            return .failure
        }
    }

    func resendCode() async {
        guard canResend else { return }
        remainingSeconds = 34
        startTimer()

        do {
            switch flowType {
            case .signUpVerification:
                _ = try await authService.resendOTP(email: email)
            case .signIn:
                _ = try await authService.requestOTPForSignIn(email: email)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func completeSignInWithOTP() async throws -> OTPResult {
        _ = try await authService.verifyOTP(email: email, otp: code)
        let isComplete = try await authService.resolveProfileCompletion()
        return isComplete ? .authenticatedComplete : .authenticatedNeedsProfile
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while remainingSeconds > 0, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                remainingSeconds -= 1
            }
        }
    }

    enum OTPResult: Equatable {
        case authenticatedComplete
        case authenticatedNeedsProfile
        case needsSetPassword(otp: String)
        case failure
    }
}
