import SwiftUI

enum LoginStep: Equatable {
    case enterEmailOrMobile
    case verifyOtp
    case enterPassword
    case registerDetails
    case onboardingExtra
    /// OTP gate shown after onboarding — user must verify email before account is created.
    case verifyRegistrationOtp
    case verifyForgotPasswordOtp
    case resetPassword
}
