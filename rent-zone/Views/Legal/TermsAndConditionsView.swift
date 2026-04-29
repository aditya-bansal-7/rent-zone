import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Terms & Conditions")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Last Updated: April 2026")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Introduction Section (User provided)
                    SectionView(
                        title: "1. Introduction — What is RentZone?",
                        content: "RentZone is a student-to-student outfit rental platform designed exclusively for college communities. Our goal is simple: help students look great for events without spending too much, while enabling them to earn money by renting out their own outfits."
                    )
                    
                    SectionView(
                        title: "2. Eligibility",
                        content: "To use RentZone, you must be a currently enrolled student at a verified college or university. You must provide a valid college email address for verification purposes."
                    )
                    
                    SectionView(
                        title: "3. Rental Agreement",
                        content: "When you rent an item, you agree to return it in the same condition as received. Any damage or late returns may result in additional charges as specified in the item listing."
                    )
                    
                    SectionView(
                        title: "4. Payments & Fees",
                        content: "RentZone facilitates payments between students. We may charge a small service fee to maintain the platform. All transactions are final once the rental period begins."
                    )
                    
                    SectionView(
                        title: "5. Content & Conduct",
                        content: "Users are responsible for the accuracy of their listings. Prohibited items include illegal goods, counterfeit items, or anything that violates campus policies."
                    )
                    
                    SectionView(
                        title: "6. Limitation of Liability",
                        content: "RentZone is a marketplace and is not responsible for the quality, safety, or legality of the items listed. Users rent at their own risk."
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

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
}

#Preview {
    TermsAndConditionsView()
}
