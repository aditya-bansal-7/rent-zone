import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Policy")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Last Updated: April 2026")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    SectionView(
                        title: "1. Information We Collect",
                        content: "We collect information you provide directly to us, such as your name, college email, profile picture, and payment information. We also collect data about your listings and rental history."
                    )
                    
                    SectionView(
                        title: "2. How We Use Information",
                        content: "We use your information to facilitate rentals, verify your student status, process payments, and improve our services. We may also use it to communicate with you about your account or platform updates."
                    )
                    
                    SectionView(
                        title: "3. Information Sharing",
                        content: "We share necessary information (like your name and location) with other users to coordinate rentals. We do not sell your personal data to third parties."
                    )
                    
                    SectionView(
                        title: "4. Data Security",
                        content: "We implement industry-standard security measures to protect your data. However, no method of transmission over the internet is 100% secure."
                    )
                    
                    SectionView(
                        title: "5. Your Choices",
                        content: "You can update your profile information at any time through the app settings. You may also request to delete your account, which will remove your personal data from our active databases."
                    )
                    
                    SectionView(
                        title: "6. Changes to This Policy",
                        content: "We may update this policy from time to time. We will notify you of any significant changes via email or an in-app notification."
                    )
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                }
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
