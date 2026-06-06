import Foundation

enum Strings {
    static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: .main, value: key, comment: "")
    }

    enum App {
        static var name: String { localized("app.name") }
    }

    enum Splash {
        static var title: String { localized("splash.title") }
    }

    enum Onboarding {
        static var title: String { localized("onboarding.title") }
        static var subtitle: String { localized("onboarding.subtitle") }
        static var signUp: String { localized("onboarding.signUp") }
        static var signIn: String { localized("onboarding.signIn") }
    }

    enum SignUp {
        static var title: String { localized("signup.title") }
        static var subtitle: String { localized("signup.subtitle") }
        static var emailPlaceholder: String { localized("signup.emailPlaceholder") }
        static var passwordPlaceholder: String { localized("signup.passwordPlaceholder") }
        static var alreadyHaveAccount: String { localized("signup.alreadyHaveAccount") }
        static var signInLink: String { localized("signup.signInLink") }
        static var button: String { localized("signup.button") }
        static var emailError: String { localized("signup.emailError") }
    }

    enum SetPassword {
        static var title: String { localized("setPassword.title") }
        static var subtitle: String { localized("setPassword.subtitle") }
        static var passwordPlaceholder: String { localized("setPassword.passwordPlaceholder") }
        static var confirmPasswordPlaceholder: String { localized("setPassword.confirmPasswordPlaceholder") }
        static var requirementsTitle: String { localized("setPassword.requirementsTitle") }
        static var requirementLength: String { localized("setPassword.requirementLength") }
        static var passwordMismatch: String { localized("setPassword.passwordMismatch") }
        static var button: String { localized("setPassword.button") }
    }

    enum SignIn {
        static var title: String { localized("signin.title") }
        static var subtitle: String { localized("signin.subtitle") }
        static var emailPlaceholder: String { localized("signin.emailPlaceholder") }
        static var passwordPlaceholder: String { localized("signin.passwordPlaceholder") }
        static var or: String { localized("signin.or") }
        static var otpButton: String { localized("signin.otpButton") }
        static var newUser: String { localized("signin.newUser") }
        static var signUpLink: String { localized("signin.signUpLink") }
        static var button: String { localized("signin.button") }
    }

    enum OTP {
        static var enterCodeTitle: String { localized("otp.enterCode.title") }
        static var enterCodeSubtitle: String { localized("otp.enterCode.subtitle") }
        static var enterOTPTitle: String { localized("otp.enterOTP.title") }
        static var enterOTPSubtitle: String { localized("otp.enterOTP.subtitle") }
        static var verifyButton: String { localized("otp.verifyButton") }
        static var signInButton: String { localized("otp.signInButton") }
        static var resendPrefix: String { localized("otp.resendPrefix") }
        static var resendAction: String { localized("otp.resendAction") }
    }

    enum Profile {
        static var title: String { localized("profile.title") }
        static var fullName: String { localized("profile.fullName") }
        static var fullNamePlaceholder: String { localized("profile.fullNamePlaceholder") }
        static var gender: String { localized("profile.gender") }
        static var genderMale: String { localized("profile.gender.male") }
        static var genderFemale: String { localized("profile.gender.female") }
        static var genderOther: String { localized("profile.gender.other") }
        static var areaCity: String { localized("profile.areaCity") }
        static var areaPlaceholder: String { localized("profile.areaPlaceholder") }
        static var birthYear: String { localized("profile.birthYear") }
        static var profession: String { localized("profile.profession") }
        static var professionStudent: String { localized("profile.profession.student") }
        static var professionWorking: String { localized("profile.profession.working") }
        static var aboutYou: String { localized("profile.aboutYou") }
        static var aboutPlaceholder: String { localized("profile.aboutPlaceholder") }
        static var next: String { localized("profile.next") }
        static var finish: String { localized("profile.finish") }
        static var required: String { localized("profile.required") }
    }

    enum Error {
        static var generic: String { localized("error.generic") }
        static var invalidEmail: String { localized("error.invalidEmail") }
        static var network: String { localized("error.network") }
    }
}
