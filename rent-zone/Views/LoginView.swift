import SwiftUI
import AuthenticationServices

enum LoginStep: Equatable {
    case enterEmailOrMobile
    case enterPassword
    case enterOTP
    case createPassword
}

struct LoginView: View {
    @State private var step: LoginStep = .enterEmailOrMobile
    @State private var emailOrMobile = ""
    @State private var password = ""
    @State private var otp = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Sheet Header with Cancel button
            HStack {
                Text(headerTitle)
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(white: 0.8))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text(headerSubtitle)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(spacing: 16) {
                        
                        // Always show email field
                        emailInput
                        
                        // Progressively show other fields with animation
                        if step == .enterPassword {
                            passwordInput
                        }
                        
                        if step == .enterOTP || step == .createPassword {
                            otpInput
                        }
                        
                        if step == .createPassword {
                            createPasswordInput
                        }
                        
                        // Action Buttons based on the current step
                        actionArea
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    termsFooter
                }
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .animation(.easeInOut(duration: 0.3), value: step)
    }
    
    // MARK: - Subviews
    
    private var emailInput: some View {
        TextField("Email or Mobile", text: $emailOrMobile)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding(16)
            .background(Color(white: 0.96))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(step != .enterEmailOrMobile ? Color.green.opacity(0.5) : Color(white: 0.9), lineWidth: 1)
            )
            .disabled(step != .enterEmailOrMobile)
            .opacity(step != .enterEmailOrMobile ? 0.6 : 1.0)
    }
    
    private var passwordInput: some View {
        SecureField("Password", text: $password)
            .padding(16)
            .background(Color(white: 0.96))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(white: 0.9), lineWidth: 1)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var otpInput: some View {
        TextField("Enter OTP Code", text: $otp)
            .keyboardType(.numberPad)
            .padding(16)
            .background(Color(white: 0.96))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(step == .createPassword ? Color.green.opacity(0.5) : Color(white: 0.9), lineWidth: 1)
            )
            .disabled(step == .createPassword)
            .opacity(step == .createPassword ? 0.6 : 1.0)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var createPasswordInput: some View {
        VStack(spacing: 16) {
            SecureField("New Password", text: $newPassword)
                .padding(16)
                .background(Color(white: 0.96))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(white: 0.9), lineWidth: 1)
                )
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding(16)
                .background(Color(white: 0.96))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(white: 0.9), lineWidth: 1)
                )
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    @ViewBuilder
    private var actionArea: some View {
        VStack(spacing: 16) {
            
            // Persistent Primary Button
            Button(action: handlePrimaryAction) {
                Text(primaryButtonTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isPrimaryButtonDisabled ? .gray : .black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isPrimaryButtonDisabled ? Color(white: 0.9) : Color(red: 243/255, green: 236/255, blue: 255/255))
                    .cornerRadius(30)
            }
            .disabled(isPrimaryButtonDisabled)
            
            // Secondary items
            if step == .enterEmailOrMobile {
                // Native UI: "or" separator
                HStack {
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                    Text("or")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                }
                .padding(.vertical, 4)
                
                // Apple Sign In Button
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            print("Authentication successful: \(authResults)")
                            dismiss()
                        case .failure(let error):
                            print("Authentication failed: \(error.localizedDescription)")
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                
            } else {
                Button(action: {
                    step = .enterEmailOrMobile
                    password = ""
                    otp = ""
                    newPassword = ""
                    confirmPassword = ""
                }) {
                    Text("Edit Email/Mobile")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .underline()
                }
                .padding(.top, 4)
            }
        }
    }
    
    private func handlePrimaryAction() {
        switch step {
        case .enterEmailOrMobile:
            guard !emailOrMobile.isEmpty else { return }
            if emailOrMobile.contains("@") && emailOrMobile.count > 5 {
                step = .enterPassword
            } else {
                step = .enterOTP
            }
        case .enterPassword:
            dismiss() // Handle Login Success
        case .enterOTP:
            step = .createPassword
        case .createPassword:
            dismiss() // Handle Auth Success
        }
    }
    
    private var primaryButtonTitle: String {
        switch step {
        case .enterEmailOrMobile: return "Continue"
        case .enterPassword: return "Sign In"
        case .enterOTP: return "Verify OTP"
        case .createPassword: return "Create Account"
        }
    }
    
    private var isPrimaryButtonDisabled: Bool {
        switch step {
        case .enterEmailOrMobile: return false
        case .enterPassword: return password.isEmpty
        case .enterOTP: return otp.count < 4
        case .createPassword: return newPassword.isEmpty || newPassword != confirmPassword
        }
    }
    
    private var termsFooter: some View {
        VStack(spacing: 4) {
            Text("By continuing, you agree to our")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Text("Terms of Service")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .underline()
                
                Text("and")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
                Text("Privacy Policy")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .underline()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
    }
    
    // MARK: - Computed Properties
    
    private var headerTitle: String {
        switch step {
        case .enterEmailOrMobile: return "Sign In"
        case .enterPassword: return "Welcome Back"
        case .enterOTP: return "Verify OTP"
        case .createPassword: return "Secure Account"
        }
    }
    
    private var headerSubtitle: String {
        switch step {
        case .enterEmailOrMobile:
            return "Enter your email or mobile number to proceed."
        case .enterPassword:
            return "Please enter the password for \(emailOrMobile)."
        case .enterOTP:
            return "We've sent a 4-digit code to \(emailOrMobile)."
        case .createPassword:
            return "Choose a secure password to finalize your account profile."
        }
    }
}

#Preview {
    Color.black.edgesIgnoringSafeArea(.all)
        .sheet(isPresented: .constant(true)) {
            LoginView()
                .presentationDetents([.fraction(0.85), .large])
        }
}
