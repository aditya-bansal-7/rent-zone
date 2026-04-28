import SwiftUI

enum LoginStep: Equatable {
    case enterEmailOrMobile
    case verifyOtp
    case enterPassword
    case registerDetails
    case onboardingExtra
}
