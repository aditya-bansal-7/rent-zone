import SwiftUI

// MARK: - Mode
private enum PasswordMode {
    case change, forgotOTPSent
}

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppStore.self) var appStore

    // MARK: Fields
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var otpCode = ""

    // MARK: State
    @State private var mode: PasswordMode = .change
    @State private var isLoading = false
    @State private var isSendingOTP = false
    @State private var fieldError: FieldError? = nil
    @State private var bannerMessage: BannerMessage? = nil

    // MARK: Focus
    @FocusState private var focusedField: Field?

    private enum Field { case old, otp, new, confirm }

    // MARK: Banner / Error helpers
    private struct BannerMessage: Identifiable {
        let id = UUID()
        let text: String
        let isError: Bool
    }
    private struct FieldError {
        let field: Field
        let message: String
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            Form {
                // ── Section 1: Old Password or OTP ─────────────────
                Section {
                    if mode == .change {
                        // Old password row
                        HStack {
                            SecureField("Current Password", text: $oldPassword)
                                .focused($focusedField, equals: .old)
                                .textContentType(.password)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .new }

                            if !oldPassword.isEmpty {
                                Button {
                                    oldPassword = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if fieldError?.field == .old {
                            Label(fieldError!.message, systemImage: "exclamationmark.circle.fill")
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .listRowSeparator(.hidden)
                        }
                    } else {
                        // OTP row
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.badge.shield.half.filled")
                                .foregroundStyle(Color.brandPurple)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Verification Code")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                TextField("Enter 6-digit code", text: $otpCode)
                                    .focused($focusedField, equals: .otp)
                                    .keyboardType(.numberPad)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .new }
                            }
                        }
                        .padding(.vertical, 4)

                        if fieldError?.field == .otp {
                            Label(fieldError!.message, systemImage: "exclamationmark.circle.fill")
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .listRowSeparator(.hidden)
                        }
                    }
                } header: {
                    Text(mode == .change ? "Current Password" : "Email Verification")
                } footer: {
                    if mode == .forgotOTPSent {
                        Text("A 6-digit code was sent to \(appStore.userStore.currentUser?.email ?? "your email").")
                    }
                }

                // ── Section 2: New Password ─────────────────────────
                Section {
                    HStack {
                        SecureField("New Password", text: $newPassword)
                            .focused($focusedField, equals: .new)
                            .textContentType(.newPassword)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .confirm }

                        if !newPassword.isEmpty {
                            Image(systemName: newPassword.count >= 6 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundStyle(newPassword.count >= 6 ? .green : .orange)
                                .font(.system(size: 16))
                        }
                    }

                    HStack {
                        SecureField("Confirm New Password", text: $confirmPassword)
                            .focused($focusedField, equals: .confirm)
                            .textContentType(.newPassword)
                            .submitLabel(.done)
                            .onSubmit { handleSubmit() }

                        if !confirmPassword.isEmpty {
                            Image(systemName: confirmPassword == newPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(confirmPassword == newPassword ? .green : .red)
                                .font(.system(size: 16))
                        }
                    }

                    if fieldError?.field == .new || fieldError?.field == .confirm {
                        Label(fieldError!.message, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .listRowSeparator(.hidden)
                    }
                } header: {
                    Text("New Password")
                } footer: {
                    Text("Minimum 6 characters.")
                }

                // ── Section 3: Action Button ────────────────────────
                Section {
                    Button(action: handleSubmit) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(Color.white)
                            } else {
                                Text(mode == .change ? "Change Password" : "Reset Password")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .foregroundStyle(Color.white)
                    .listRowBackground(isSubmitDisabled ? Color.brandPurple.opacity(0.4) : Color.brandPurple)
                    .disabled(isSubmitDisabled || isLoading)
                }

                // ── Section 4: Forgot / Resend ──────────────────────
                Section {
                    if mode == .change {
                        Button {
                            requestOTP()
                        } label: {
                            HStack {
                                if isSendingOTP {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.85)
                                }
                                Text(isSendingOTP ? "Sending code…" : "Forgot Current Password?")
                                    .foregroundStyle(isSendingOTP ? Color.secondary : Color.brandPurple)
                            }
                        }
                        .disabled(isSendingOTP)
                    } else {
                        Button {
                            requestOTP()
                        } label: {
                            HStack {
                                if isSendingOTP {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.85)
                                }
                                Text(isSendingOTP ? "Sending…" : "Resend Code")
                                    .foregroundStyle(isSendingOTP ? Color.secondary : Color.brandPurple)
                            }
                        }
                        .disabled(isSendingOTP)

                        Button {
                            withAnimation { mode = .change }
                            otpCode = ""
                            fieldError = nil
                        } label: {
                            Text("Use Current Password Instead")
                                .foregroundStyle(Color.brandPurple)
                        }
                    }
                }
            }

            // ── Inline banner (success / error) ────────────────────
            if let banner = bannerMessage {
                HStack(spacing: 10) {
                    Image(systemName: banner.isError ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundStyle(banner.isError ? .red : .green)
                    Text(banner.text)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(banner.isError ? .red : .green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture { withAnimation { bannerMessage = nil } }
                .zIndex(1)
            }
        }
        .navigationTitle(mode == .change ? "Change Password" : "Reset Password")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: mode)
        .animation(.easeInOut(duration: 0.25), value: bannerMessage?.id)
    }

    // MARK: - Computed
    private var isSubmitDisabled: Bool {
        let passwordsFilled = !newPassword.isEmpty && !confirmPassword.isEmpty
        let sourceFilled = mode == .change ? !oldPassword.isEmpty : otpCode.count == 6
        return !passwordsFilled || !sourceFilled
    }

    // MARK: - Actions
    private func handleSubmit() {
        fieldError = nil
        guard newPassword.count >= 6 else {
            fieldError = FieldError(field: .new, message: "Password must be at least 6 characters.")
            return
        }
        guard newPassword == confirmPassword else {
            fieldError = FieldError(field: .confirm, message: "Passwords do not match.")
            return
        }

        if mode == .change {
            guard !oldPassword.isEmpty else {
                fieldError = FieldError(field: .old, message: "Please enter your current password.")
                return
            }
            performChangePassword()
        } else {
            guard otpCode.count == 6 else {
                fieldError = FieldError(field: .otp, message: "Please enter the 6-digit code.")
                return
            }
            performResetPassword()
        }
    }

    private func performChangePassword() {
        isLoading = true
        Task {
            do {
                try await AuthService.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                await MainActor.run {
                    isLoading = false
                    showBanner("Password changed successfully!", isError: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    fieldError = FieldError(field: .old, message: error.localizedDescription)
                    showBanner(error.localizedDescription, isError: true)
                }
            }
        }
    }

    private func performResetPassword() {
        guard let email = appStore.userStore.currentUser?.email else { return }
        isLoading = true
        Task {
            do {
                try await AuthService.shared.resetPassword(email: email, code: otpCode, newPassword: newPassword)
                await MainActor.run {
                    isLoading = false
                    showBanner("Password reset successfully!", isError: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    fieldError = FieldError(field: .otp, message: error.localizedDescription)
                    showBanner(error.localizedDescription, isError: true)
                }
            }
        }
    }

    private func requestOTP() {
        guard let email = appStore.userStore.currentUser?.email else {
            showBanner("No email found. Please log out and reset from the login screen.", isError: true)
            return
        }
        isSendingOTP = true
        Task {
            do {
                try await AuthService.shared.sendOtp(email: email)
                await MainActor.run {
                    isSendingOTP = false
                    withAnimation { mode = .forgotOTPSent }
                    otpCode = ""
                    fieldError = nil
                    showBanner("Code sent to \(email)!", isError: false)
                }
            } catch {
                await MainActor.run {
                    isSendingOTP = false
                    showBanner("Failed to send code: \(error.localizedDescription)", isError: true)
                }
            }
        }
    }

    private func showBanner(_ text: String, isError: Bool) {
        withAnimation {
            bannerMessage = BannerMessage(text: text, isError: isError)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { bannerMessage = nil }
        }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
            .environment(AppStore())
    }
}
