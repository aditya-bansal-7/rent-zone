import SwiftUI

struct TermsFooter: View {
    var body: some View {
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
}
