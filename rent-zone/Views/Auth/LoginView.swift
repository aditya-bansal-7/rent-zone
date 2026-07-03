import SwiftUI
import AuthenticationServices

import GoogleSignIn


struct LoginView: View {
    @State private var step: LoginStep = .enterEmailOrMobile
    @State private var emailOrMobile = ""
    @State private var password = ""
    @State private var name = ""
    @State private var location = ""
    @State private var university = ""
    @State private var phoneNumber = ""
    @State private var selectedCategory: CategoryType = .women
    @State private var otpCode = ""
    /// True only when the user authenticated via OAuth (Google/Apple) and is completing onboarding.
    /// Routes the final step through `updateProfile` instead of `register`.
    @State private var isOAuthOnboarding = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var resetToken = ""

    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore

    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 16) {
                        inputsArea
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 4)
                        }
                        
                        actionsArea
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    Spacer()
                    TermsFooter()
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // MARK: - Subviews
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(headerTitle)
                    .font(.system(size: 34, weight: .bold)) // Apple large title
                    .foregroundColor(.primary)
                
                
                Text(headerSubtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(10)
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
            }
            .padding(.top, 16)
            .padding(.trailing, 4)
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var inputsArea: some View {
        if step != .onboardingExtra && step != .verifyRegistrationOtp && step != .verifyForgotPasswordOtp && step != .resetPassword {
            AuthInputField(
                placeholder: "Email address",
                text: $emailOrMobile,
                keyboardType: .emailAddress,
                isDisabled: step != .enterEmailOrMobile && step != .registerDetails,
                isSuccess: step != .enterEmailOrMobile && step != .registerDetails
            )
        }
        
        if step == .verifyOtp || step == .verifyRegistrationOtp || step == .verifyForgotPasswordOtp {
            AuthInputField(
                placeholder: "Verification Code",
                text: $otpCode,
                keyboardType: .numberPad
            )
            .transition(.move(edge: .top).combined(with: .opacity))
            
            Button(action: { Task { await performSendOtp() } }) {
                Text("Resend Code")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.brandPurple)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, -8)
        }
        
        if step == .enterPassword || step == .registerDetails || step == .resetPassword {
            AuthInputField(placeholder: step == .resetPassword ? "New Password" : "Password", text: $password, isSecure: true)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
        
        if step == .registerDetails {
            AuthInputField(placeholder: "Full Name", text: $name)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
        
        if step == .onboardingExtra {
            AuthOnboardingStepView(
                location: $location,
                university: $university,
                phoneNumber: $phoneNumber,
                selectedCategory: $selectedCategory
            )
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    private var actionsArea: some View {
        VStack(spacing: 16) {
            PrimaryAuthButton(
                title: primaryButtonTitle,
                action: handlePrimaryAction,
                isLoading: isLoading,
                isDisabled: isPrimaryButtonDisabled
            )
            
            if step == .enterEmailOrMobile {
                SocialAuthButtons(
                    onAppleCompletion: handleAppleSignIn,
                    onGoogleAction: handleGoogleSignIn
                )
                
                
                Button(action: { withAnimation { step = .registerDetails } }) {
                    HStack(spacing: 4) {
                        Text("New to RentZone?")
                            .foregroundColor(.gray)
                        Text("Create Account")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .font(.system(size: 14))
                }
                .padding(.top, 8)
            } else {
                Button(action: handleGoBack) {
                    Text("Go Back")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .underline()
                }
                .padding(.top, 4)
                
                if step == .verifyOtp {
                    Button(action: { withAnimation { step = .enterPassword } }) {
                        Text("Use Password instead")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.top, 4)
                }
                
                if step == .enterPassword {
                    HStack {
                        Button(action: { Task { await performSendOtp() } }) {
                            Text("Use OTP instead")
                                .font(.system(size: 14, weight: .medium))
                        }
                        
                        Spacer()
                        
                        Button(action: { Task { await performSendForgotPasswordOtp() } }) {
                            Text("Forgot Password?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Logic Handlers
    
    private func handleGoBack() {
        errorMessage = nil
        if step == .verifyRegistrationOtp {
            withAnimation { step = .onboardingExtra }
        } else if step == .onboardingExtra {
            withAnimation { step = .registerDetails }
        } else if step == .verifyForgotPasswordOtp {
            withAnimation { step = .enterPassword }
        } else if step == .resetPassword {
            withAnimation { step = .enterPassword }
        } else {
            withAnimation { step = .enterEmailOrMobile }
        }
    }

    private func handlePrimaryAction() {
        errorMessage = nil
        switch step {
        case .enterEmailOrMobile:
            guard emailOrMobile.contains("@") && emailOrMobile.count > 5 else {
                errorMessage = "Please enter a valid email address"
                return
            }
            withAnimation { step = .enterPassword }
        case .verifyOtp:
            guard otpCode.count == 6 else {
                errorMessage = "Please enter the 6-digit code"
                return
            }
            Task { await performVerifyOtp() }
        case .enterPassword:
            Task { await performLogin() }
        case .registerDetails:
            guard !name.isEmpty else {
                errorMessage = "Please enter your full name"
                return
            }
            withAnimation { step = .onboardingExtra }
        case .onboardingExtra:
            // Send OTP to verify email before creating the account
            Task { await performSendRegistrationOtp() }
        case .verifyRegistrationOtp:
            guard otpCode.count == 6 else {
                errorMessage = "Please enter the 6-digit verification code"
                return
            }
            Task { await performVerifyRegistrationOtpAndRegister() }
        case .verifyForgotPasswordOtp:
            guard otpCode.count == 6 else {
                errorMessage = "Please enter the 6-digit code"
                return
            }
            Task { await performVerifyForgotPasswordOtp() }
        case .resetPassword:
            guard password.count >= 6 else {
                errorMessage = "Password must be at least 6 characters"
                return
            }
            Task { await performResetPassword() }
        }
    }

    private func performSendOtp() async {
        isLoading = true
        do {
            try await AuthService.shared.sendOtp(email: emailOrMobile)
            await MainActor.run {
                self.isLoading = false
                self.otpCode = ""
                withAnimation { self.step = .verifyOtp }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func performSendForgotPasswordOtp() async {
        isLoading = true
        do {
            try await AuthService.shared.sendOtp(email: emailOrMobile)
            await MainActor.run {
                self.isLoading = false
                self.otpCode = ""
                withAnimation { self.step = .verifyForgotPasswordOtp }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func performSendRegistrationOtp() async {
        isLoading = true
        do {
            try await AuthService.shared.sendOtp(email: emailOrMobile)
            await MainActor.run {
                self.isLoading = false
                self.otpCode = ""
                withAnimation { self.step = .verifyRegistrationOtp }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func performVerifyOtp() async {
        isLoading = true
        do {
            let result = try await AuthService.shared.verifyOtp(email: emailOrMobile, code: otpCode)
            await MainActor.run {
                self.isLoading = false
                if result.isNewUser == true {
                    withAnimation { self.step = .registerDetails }
                } else {
                    Task {
                        await appStore.refreshAfterLogin()
                        await MainActor.run { dismiss() }
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func performLogin() async {
        isLoading = true
        do {
            _ = try await appStore.userStore.login(email: emailOrMobile, password: password)
            await appStore.refreshAfterLogin()
            await MainActor.run {
                self.isLoading = false
                dismiss()
            }
        } catch let error as APIError {
            await MainActor.run {
                self.isLoading = false
                if case .serverError(let msg) = error {
                    if msg.lowercased().contains("invalid") {
                        self.errorMessage = "\(msg). New here? Fill in your details to register."
                        withAnimation { self.step = .registerDetails }
                    } else {
                        self.errorMessage = msg
                    }
                } else {
                    self.errorMessage = error.localizedDescription
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func performRegister() async {
        isLoading = true
        do {
            // OAuth users (Google/Apple) already have an account — update their profile.
            // Fresh email signups always use register, regardless of any stale token.
            if isOAuthOnboarding {
                _ = try await appStore.userStore.updateProfile(
                    name: name,
                    location: location.isEmpty ? "Unknown" : location,
                    university: university,
                    phoneNumber: phoneNumber,
                    preferredCategory: selectedCategory.rawValue
                )
            } else {
                _ = try await appStore.userStore.register(
                    name: name,
                    email: emailOrMobile,
                    password: password,
                    location: location.isEmpty ? "Unknown" : location,
                    university: university,
                    phoneNumber: phoneNumber,
                    preferredCategory: selectedCategory.rawValue
                )
            }
            await appStore.refreshAfterLogin()
            await MainActor.run {
                self.isLoading = false
                dismiss()
            }
        } catch let error as APIError {
            await MainActor.run {
                self.isLoading = false
                if case .serverError(let msg) = error {
                    self.errorMessage = msg
                } else {
                    self.errorMessage = error.localizedDescription
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func performVerifyRegistrationOtpAndRegister() async {
        isLoading = true
        do {
            // The backend verifyOtp call will return isNewUser:true and no tokens for a new email.
            // We only need it to confirm the code is valid — then proceed to register.
            let result = try await AuthService.shared.verifyOtp(email: emailOrMobile, code: otpCode)
            // If the email already has an account (isNewUser == false), tokens were returned — log in.
            if result.isNewUser == false {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "This email is already registered. Logging you in instead."
                }
                Task {
                    await appStore.refreshAfterLogin()
                    await MainActor.run { dismiss() }
                }
                return
            }
            // New user — proceed to create the account.
            await MainActor.run { self.otpCode = "" }
            await performRegister()
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func performVerifyForgotPasswordOtp() async {
        isLoading = true
        do {
            let token = try await AuthService.shared.verifyForgotPasswordOtp(email: emailOrMobile, code: otpCode)
            await MainActor.run {
                self.isLoading = false
                self.resetToken = token
                self.password = ""
                withAnimation { self.step = .resetPassword }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func performResetPassword() async {
        isLoading = true
        do {
            try await AuthService.shared.resetPassword(resetToken: resetToken, newPassword: password)
            // Log them in automatically with the new password
            _ = try await appStore.userStore.login(email: emailOrMobile, password: password)
            await appStore.refreshAfterLogin()
            await MainActor.run {
                self.isLoading = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func handleGoogleSignIn() {
        Task {
            isLoading = true
            do {
                let result = try await GoogleSignInHelper.shared.signIn()
                guard let idToken = result.user.idToken?.tokenString else {
                    errorMessage = "Failed to get ID token from Google"
                    isLoading = false
                    return
                }
                
                let authResult = try await AuthService.shared.oauthLogin(
                    name: result.user.profile?.name,
                    provider: "google",
                    idToken: idToken
                )
                
                
                await appStore.refreshAfterLogin()
                
                await MainActor.run {
                    self.isLoading = false
                    self.name = result.user.profile?.name ?? "User"
                    self.emailOrMobile = result.user.profile?.email ?? ""
                    self.password = UUID().uuidString.prefix(8).description
                    let needsOnboarding = authResult.isNewUser || 
                                         authResult.user.location.isEmpty || 
                                         (authResult.user.university ?? "").isEmpty
                    
                    if needsOnboarding {
                        self.isOAuthOnboarding = true
                        withAnimation { self.step = .onboardingExtra }
                    } else {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }


    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResult):
            guard let appleIDCredential = authResult.credential as? ASAuthorizationAppleIDCredential else { return }
            
            let name = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                errorMessage = "Failed to get identity token from Apple"
                return
            }
            
            Task {
                isLoading = true
                do {
                    let result = try await AuthService.shared.oauthLogin(
                        name: name.isEmpty ? nil : name,
                        provider: "apple",
                        idToken: tokenString
                    )
                    
                    await appStore.refreshAfterLogin()
                    
                    await MainActor.run {
                        self.isLoading = false
                        let needsOnboarding = result.isNewUser || 
                                             result.user.location.isEmpty || 
                                             (result.user.university ?? "").isEmpty
                        
                        if needsOnboarding {
                            self.isOAuthOnboarding = true
                            withAnimation { self.step = .onboardingExtra }
                        } else {
                            dismiss()
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Computed Props
    
    private var primaryButtonTitle: String {
        switch step {
        case .enterEmailOrMobile: return "Continue"
        case .verifyOtp: return "Verify Code"
        case .enterPassword: return "Sign In"
        case .registerDetails: return "Continue"
        case .onboardingExtra: return "Send Verification Code"
        case .verifyRegistrationOtp: return "Verify & Create Account"
        case .verifyForgotPasswordOtp: return "Verify Code"
        case .resetPassword: return "Reset & Sign In"
        }
    }

    private var isPrimaryButtonDisabled: Bool {
        switch step {
        case .enterEmailOrMobile: return emailOrMobile.isEmpty
        case .verifyOtp: return otpCode.count < 6
        case .enterPassword: return password.isEmpty
        case .registerDetails: return name.isEmpty
        case .onboardingExtra: return location.isEmpty || university.isEmpty
        case .verifyRegistrationOtp: return otpCode.count < 6
        case .verifyForgotPasswordOtp: return otpCode.count < 6
        case .resetPassword: return password.count < 6
        }
    }

    private var headerTitle: String {
        switch step {
        case .enterEmailOrMobile: return "Sign In"
        case .verifyOtp: return "Verify Email"
        case .enterPassword: return "Welcome Back"
        case .registerDetails: return "Create Account"
        case .onboardingExtra: return "Final Touches"
        case .verifyRegistrationOtp: return "Verify Your Email"
        case .verifyForgotPasswordOtp: return "Reset Password"
        case .resetPassword: return "New Password"
        }
    }

    private var headerSubtitle: String {
        switch step {
        case .enterEmailOrMobile: return "Enter your email to sign in or create an account."
        case .verifyOtp: return "We've sent a 6-digit code to \(emailOrMobile)."
        case .enterPassword: return "Enter the password for \(emailOrMobile)."
        case .registerDetails: return "Enter your name and password to create an account."
        case .onboardingExtra: return "Tell us a bit more about yourself to personalize your experience."
        case .verifyRegistrationOtp: return "We've sent a 6-digit code to \(emailOrMobile). Verify your email to complete account creation."
        case .verifyForgotPasswordOtp: return "We've sent a 6-digit code to \(emailOrMobile)."
        case .resetPassword: return "Create a new strong password."
        }
    }
}
