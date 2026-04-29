import SwiftUI

struct TermsFooter: View {
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text("By continuing, you agree to our")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)

            HStack(spacing: 4) {
                Button {
                    showTerms = true
                } label: {
                    Text("Terms of Service")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .underline()
                }

                Text("and")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)

                Button {
                    showPrivacy = true
                } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .underline()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
        .sheet(isPresented: $showTerms) {
            TermsAndConditionsView()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
    }
}
