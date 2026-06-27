import SwiftUI
import AuthenticationServices

struct AuthInputField: View {
    let placeholder: String
    @Binding var text: String
    var iconName: String? = nil
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var isDisabled: Bool = false
    var isSuccess: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if let iconName {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 24)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

struct PrimaryAuthButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isDisabled ? .secondary : .white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(isDisabled ? Color(uiColor: .tertiarySystemFill) : Color.brandPurple)
            .cornerRadius(16)
            .shadow(color: isDisabled ? .clear : Color.brandPurple.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .disabled(isDisabled || isLoading)
    }
}

struct SocialAuthButtons: View {
    let onAppleCompletion: (Result<ASAuthorization, Error>) -> Void
    let onGoogleAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
                Text("or")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            }
            .padding(.vertical, 4)

            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: onAppleCompletion
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

            Button(action: onGoogleAction) {
                HStack(spacing: 12) {
                    Image("google-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.primary)
                    Text("Continue with Google")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
            }
        }
    }
}
