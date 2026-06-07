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
    private let authService: AuthServiceProtocol
    private var timerTask: Task<Void, Never>?

    private let codeLength = 4

    init(
        flowType: OTPFlowType,
        email: String,
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.flowType = flowType
        self.email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.authService = authService
        // #region agent log
        DebugLog.write(
            location: "OTPViewModel.swift:init",
            message: "OTP screen opened",
            data: [
                "flowType": String(describing: flowType),
                "emailDomain": String(self.email.split(separator: "@").last ?? "")
            ],
            hypothesisId: "E"
        )
        print("[RoominateAuth] OTPView opened flow=\(flowType) email=\(self.email)")
        // #endregion
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
                // #region agent log
                DebugLog.write(
                    location: "OTPViewModel.swift:verify",
                    message: "Sign-up OTP captured; deferring verify-otp until password is set",
                    data: ["emailDomain": String(email.split(separator: "@").last ?? "")],
                    hypothesisId: "A"
                )
                // #endregion
                return .needsSetPassword(otp: code)

            case .signIn:
                return try await completeSignInWithOTP()
            }
        } catch {
            errorMessage = error.localizedDescription
            // #region agent log
            DebugLog.write(
                location: "OTPViewModel.swift:verify",
                message: "OTP verification failed",
                data: [
                    "flowType": String(describing: flowType),
                    "error": error.localizedDescription
                ],
                hypothesisId: "E"
            )
            // #endregion
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
            // #region agent log
            DebugLog.write(
                location: "OTPViewModel.swift:resendCode",
                message: "OTP resent successfully",
                data: ["emailDomain": String(email.split(separator: "@").last ?? "")],
                hypothesisId: "B"
            )
            // #endregion
        } catch {
            errorMessage = error.localizedDescription
            // #region agent log
            DebugLog.write(
                location: "OTPViewModel.swift:resendCode",
                message: "OTP resend failed",
                data: ["error": error.localizedDescription],
                hypothesisId: "B"
            )
            // #endregion
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
