import SwiftUI

struct HelpAndSupportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("FAQs")) {
                    NavigationLink(destination: FAQDetailView(title: "How to rent?", content: "To rent an outfit, browse the categories, select an item, choose your dates, and proceed to checkout. Coordinate with the lender via chat for pickup.")) {
                        Text("How to rent?")
                    }
                    NavigationLink(destination: FAQDetailView(title: "How to list an item?", content: "Go to the Upload tab, take photos of your outfit, add a description and price, and publish it for others to see.")) {
                        Text("How to list an item?")
                    }
                    NavigationLink(destination: FAQDetailView(title: "Payment safety", content: "All payments are processed securely. Funds are held until the rental is successfully initiated.")) {
                        Text("Payment safety")
                    }
                }
                
                Section(header: Text("Contact Us")) {
                    Button(action: {
                        // Open email
                    }) {
                        Label("Email Support", systemImage: "envelope")
                    }
                    Button(action: {
                        // Open chat
                    }) {
                        Label("Live Chat", systemImage: "bubble.left.and.right")
                    }
                }
                
                Section(header: Text("Feedback")) {
                    Button(action: {}) {
                        Label("Report a Bug", systemImage: "ladybug")
                    }
                    Button(action: {}) {
                        Label("Suggest a Feature", systemImage: "lightbulb")
                    }
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FAQDetailView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HelpAndSupportView()
}
