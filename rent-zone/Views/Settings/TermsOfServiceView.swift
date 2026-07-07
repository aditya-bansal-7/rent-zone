import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("Last updated: July 2026")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. Introduction")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Welcome to Rent Zone. By accessing or using our mobile application, you agree to be bound by these Terms of Service. Rent Zone provides a peer-to-peer platform for users to list, discover, and rent fashion items and accessories.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("2. User Responsibilities")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("As a user, you agree to provide accurate information when listing items and to treat all rented items with care. Lenders are responsible for ensuring items match their descriptions. Renters are responsible for returning items on time and in the condition they were received.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("3. Virtual Try-On")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Our Virtual Try-On feature uses artificial intelligence to estimate fit. Results are approximations and we do not guarantee an exact real-life fit. Photos uploaded for this feature are processed securely and are not permanently stored on our servers.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("4. Payments and Fees")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Rent Zone facilitates secure payments between users. A service fee may be applied to transactions. In the event of damage or late returns, Rent Zone reserves the right to charge the renter's payment method for repair or replacement costs as outlined in our Damage Policy.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("5. Termination")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("We reserve the right to suspend or terminate your account at our discretion if you violate these Terms, receive consistent negative reviews, or engage in fraudulent activities.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
                Text("If you have any questions about these Terms, please contact us at rentzone0@gmail.com.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
            }
            .padding(24)
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    NavigationView {
        TermsOfServiceView()
    }
}
