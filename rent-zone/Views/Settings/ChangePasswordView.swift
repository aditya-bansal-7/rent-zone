import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppStore.self) var appStore
    
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    // OTP Reset Mode
    @State private var isForgotPasswordMode = false
    @State private var otpCode = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAlert = false
    @State private var isSuccess = false
    
    var body: some View {
        Form {
            if isForgotPasswordMode {
                Section(header: Text("Verification Code"), footer: Text("Enter the 6-digit code sent to your email.")) {
                    SecureField("6-Digit OTP Code", text: $otpCode)
                        .keyboardType(.numberPad)
                }
            } else {
                Section(header: Text("Current Password")) {
                    SecureField("Old Password", text: $oldPassword)
                }
            }
            
            Section(header: Text("New Password"), footer: Text("Password must be at least 6 characters long.")) {
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmPassword)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .listRowBackground(Color.clear)
            }
            
            Section {
                Button(action: isForgotPasswordMode ? resetPassword : changePassword) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text(isForgotPasswordMode ? "Reset Password" : "Change Password")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
                .listRowBackground(Color.blue)
                .disabled(isLoading || newPassword.isEmpty || confirmPassword.isEmpty || (isForgotPasswordMode ? otpCode.isEmpty : oldPassword.isEmpty))
            }
            
            if !isForgotPasswordMode {
                Section {
                    Button(action: requestOTP) {
                        Text("Forgot Old Password?")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle(isForgotPasswordMode ? "Reset Password" : "Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isSuccess ? "Success" : "Error", isPresented: $showingAlert) {
            Button("OK") {
                if isSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(isSuccess ? "Your password has been updated successfully." : (errorMessage ?? "An unknown error occurred."))
        }
    }
    
    private func changePassword() {
        if newPassword.count < 6 {
            errorMessage = "New password must be at least 6 characters."
            return
        }
        if newPassword != confirmPassword {
            errorMessage = "New passwords do not match."
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await AuthService.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                await MainActor.run {
                    isLoading = false
                    isSuccess = true
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
    
    private func resetPassword() {
        guard let email = appStore.userStore.currentUser?.email else {
            errorMessage = "Could not find your email."
            return
        }
        
        if newPassword.count < 6 {
            errorMessage = "New password must be at least 6 characters."
            return
        }
        if newPassword != confirmPassword {
            errorMessage = "New passwords do not match."
            return
        }
        if otpCode.count != 6 {
            errorMessage = "Please enter a valid 6-digit OTP."
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await AuthService.shared.resetPassword(email: email, code: otpCode, newPassword: newPassword)
                await MainActor.run {
                    isLoading = false
                    isSuccess = true
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
    
    private func requestOTP() {
        guard let email = appStore.userStore.currentUser?.email else {
            errorMessage = "No email associated with this account. Please log out and use 'Forgot Password' on the login screen."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await AuthService.shared.sendOtp(email: email)
                await MainActor.run {
                    isLoading = false
                    withAnimation {
                        isForgotPasswordMode = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ChangePasswordView()
            .environment(AppStore())
    }
}
