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
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore

    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    subtitle
                    
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
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // MARK: - Subviews
    
    private var header: some View {
        HStack {
            Text(headerTitle)
                .font(.system(size: 24, weight: .bold))
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(white: 0.8))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 8)
    }
    
    private var subtitle: some View {
        Text(headerSubtitle)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(.gray)
            .lineSpacing(4)
            .padding(.horizontal, 24)
            .padding(.top, 4)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    private var inputsArea: some View {
        if step != .onboardingExtra {
            AuthInputField(
                placeholder: "Email address",
                text: $emailOrMobile,
                keyboardType: .emailAddress,
                isDisabled: step != .enterEmailOrMobile,
                isSuccess: step != .enterEmailOrMobile
            )
        }
        
        if step == .verifyOtp {
            AuthInputField(
                placeholder: "Verification Code",
                text: $otpCode,
                keyboardType: .numberPad
            )
            .transition(.move(edge: .top).combined(with: .opacity))
            
            Button(action: { Task { await performSendOtp() } }) {
                Text("Resend Code")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, -8)
        }
        
        if step == .enterPassword || step == .registerDetails {
            AuthInputField(placeholder: "Password", text: $password, isSecure: true)
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
                
                Button(action: { 
                    if emailOrMobile.contains("@") && emailOrMobile.count > 5 {
                        withAnimation { step = .enterPassword }
                    } else {
                        errorMessage = "Please enter your email first to login with password"
                    }
                }) {
                    Text("Login with Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.top, 4)
                
                Button(action: { withAnimation { step = .registerDetails } }) {
                    HStack(spacing: 4) {
                        Text("New to RentZone?")
                            .foregroundColor(.gray)
                        Text("Create Account")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
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
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
                
                if step == .enterPassword {
                    Button(action: { Task { await performSendOtp() } }) {
                        Text("Use OTP instead")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Logic Handlers
    
    private func handleGoBack() {
        if step == .onboardingExtra {
            step = .registerDetails
        } else {
            step = .enterEmailOrMobile
        }
        errorMessage = nil
    }

    private func handlePrimaryAction() {
        errorMessage = nil
        switch step {
        case .enterEmailOrMobile:
            guard emailOrMobile.contains("@") && emailOrMobile.count > 5 else {
                errorMessage = "Please enter a valid email address"
                return
            }
            Task { await performSendOtp() }
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
            Task { await performRegister() }
        }
    }

    private func performSendOtp() async {
        isLoading = true
        do {
            try await AuthService.shared.sendOtp(email: emailOrMobile)
            await MainActor.run {
                self.isLoading = false
                withAnimation { self.step = .verifyOtp }
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
            if TokenStorage.isLoggedIn {
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
                if case .serverError(let msg) = error as? APIError {
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
                        withAnimation {
                            self.step = .onboardingExtra
                        }
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
                            withAnimation {
                                self.step = .onboardingExtra
                            }
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
        case .onboardingExtra: return "Create Account"
        }
    }

    private var isPrimaryButtonDisabled: Bool {
        switch step {
        case .enterEmailOrMobile: return emailOrMobile.isEmpty
        case .verifyOtp: return otpCode.count < 6
        case .enterPassword: return password.isEmpty
        case .registerDetails: return name.isEmpty
        case .onboardingExtra: return location.isEmpty || university.isEmpty
        }
    }

    private var headerTitle: String {
        switch step {
        case .enterEmailOrMobile: return "Sign In"
        case .verifyOtp: return "Verify Email"
        case .enterPassword: return "Welcome Back"
        case .registerDetails: return "Create Account"
        case .onboardingExtra: return "Final Touches"
        }
    }

    private var headerSubtitle: String {
        switch step {
        case .enterEmailOrMobile: return "Enter your email to sign in or create an account."
        case .verifyOtp: return "We've sent a 6-digit code to \(emailOrMobile)."
        case .enterPassword: return "Enter the password for \(emailOrMobile)."
        case .registerDetails: return "Enter your name and password to create an account."
        case .onboardingExtra: return "Tell us a bit more about yourself to personalize your experience."
        }
    }
}
