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
        HStack {
            if let iconName {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .frame(width: 20)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSuccess ? Color.green.opacity(0.5) : Color(UIColor.separator), lineWidth: 1)
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDisabled ? .gray : .white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isDisabled ? Color(UIColor.tertiarySystemFill) : Color.brandPurple)
            .cornerRadius(30)
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
                Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                Text("or")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
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
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 30))

            Button(action: onGoogleAction) {
                HStack(spacing: 12) {
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.brandPurple)
                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
        }
    }
}
