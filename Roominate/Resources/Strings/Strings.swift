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
        static var instituteLabel: String { localized("profile.institute.label") }
        static var institutePlaceholder: String { localized("profile.institute.placeholder") }
        static var organizationLabel: String { localized("profile.organization.label") }
        static var organizationPlaceholder: String { localized("profile.organization.placeholder") }
        static var aboutYou: String { localized("profile.aboutYou") }
        static var aboutPlaceholder: String { localized("profile.aboutPlaceholder") }
        static var next: String { localized("profile.next") }
        static var finish: String { localized("profile.finish") }
        static var required: String { localized("profile.required") }
        static var settingsTitle: String { localized("profile.settingsTitle") }
        static var notification: String { localized("profile.notification") }
        static var blockedUsers: String { localized("profile.blockedUsers") }
        static var aboutUs: String { localized("profile.aboutUs") }
        static var contactUs: String { localized("profile.contactUs") }
        static var reportProblem: String { localized("profile.reportProblem") }
        static var help: String { localized("profile.help") }
        static var shareApp: String { localized("profile.shareApp") }
        static var logOut: String { localized("profile.logOut") }
        static var deleteAccount: String { localized("profile.deleteAccount") }
        static var deleteAccountTitle: String { localized("profile.deleteAccountTitle") }
        static var deleteAccountMessage: String { localized("profile.deleteAccountMessage") }
        static var deleteAccountConfirm: String { localized("profile.deleteAccountConfirm") }
        static var myProfile: String { localized("profile.myProfile") }
        static var myPreferences: String { localized("profile.myPreferences") }
        static var favorites: String { localized("profile.favorites") }
        static var communities: String { localized("profile.communities") }
        static var contactSupport: String { localized("profile.contactSupport") }
        static var privacyPolicy: String { localized("profile.privacyPolicy") }
        static var guestUser: String { localized("profile.guestUser") }
        static var personalInformation: String { localized("profile.personalInformation") }
        static var contactAndPrimary: String { localized("profile.contactAndPrimary") }
        static var age: String { localized("profile.age") }
        static var position: String { localized("profile.position") }
        static var positionPlaceholder: String { localized("profile.positionPlaceholder") }
        static var email: String { localized("profile.email") }
        static var emailVerified: String { localized("profile.emailVerified") }
        static var socialLinks: String { localized("profile.socialLinks") }
        static var addSocialLink: String { localized("profile.addSocialLink") }
        static var socialLinkPlaceholder: String { localized("profile.socialLinkPlaceholder") }
        static var update: String { localized("profile.update") }
        static var aboutEmpty: String { localized("profile.aboutEmpty") }
        static var birthYearPlaceholder: String { localized("profile.birthYearPlaceholder") }
        static var removePhoto: String { localized("profile.removePhoto") }
        static var removePhotoTitle: String { localized("profile.removePhotoTitle") }
        static var basicInformation: String { localized("profile.basicInformation") }
        static var contactAndPrivacy: String { localized("profile.contactAndPrivacy") }
        static var currentCity: String { localized("profile.currentCity") }
        static var listing: String { localized("profile.listing") }
        static var noListingYet: String { localized("profile.noListingYet") }
        static var addPost: String { localized("profile.addPost") }
        static var lifestyleNotes: String { localized("profile.lifestyleNotes") }
        static var editListing: String { localized("profile.editListing") }
        static var deleteListing: String { localized("profile.deleteListing") }
        static var deleteListingTitle: String { localized("profile.deleteListingTitle") }
        static var deleteListingMessage: String { localized("profile.deleteListingMessage") }
        static var myPosts: String { localized("profile.myPosts") }
        static var aboutCardTitle: String { localized("profile.aboutCardTitle") }
        static var searchPerson: String { localized("profile.searchPerson") }
        static var unblock: String { localized("profile.unblock") }
        static var noBlockedUsers: String { localized("profile.noBlockedUsers") }
        static var noSearchResults: String { localized("profile.noSearchResults") }
        static var aboutUsDescription: String { localized("profile.aboutUsDescription") }
        static var deleteAccountReasonPrompt: String { localized("profile.deleteAccountReasonPrompt") }
        static var deleteAccountOTPSent: String { localized("profile.deleteAccountOTPSent") }
        static var verifyAndDelete: String { localized("profile.verifyAndDelete") }
        static var cancel: String { localized("profile.cancel") }
    }

    enum Common {
        static var loading: String { localized("common.loading") }
    }

    enum Error {
        static var generic: String { localized("error.generic") }
        static var invalidCredentials: String { localized("error.invalidCredentials") }
        static var invalidEmail: String { localized("error.invalidEmail") }
        static var network: String { localized("error.network") }
    }
}
