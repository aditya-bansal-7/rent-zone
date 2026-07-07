import SwiftUI

struct HelpAndSupportView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showBugReport = false
    @State private var showFeatureRequest = false
    @State private var showEmailAlert = false
    
    var body: some View {
        List {
                Section(header: Text("FAQs")) {
                    NavigationLink(destination: FAQDetailView(title: "How to rent?", content: "To rent an outfit, browse the categories, select an item, choose your dates, and proceed to checkout. Coordinate with the lender via chat for pickup.")) {
                        Text("How to rent?")
                    }
                    NavigationLink(destination: FAQDetailView(title: "How to list an item?", content: "Go to the Upload tab, take photos of your outfit, add a description and price, and publish it for others to see.")) {
                        Text("How to list an item?")
                    }
                    NavigationLink(destination: FAQDetailView(title: "Virtual Try-On", content: "To use the Virtual Try-On feature, select a compatible outfit and tap 'Virtual Try-On'. Upload a clear, full-body photo of yourself to see how the outfit looks on you before renting!")) {
                        Text("Virtual Try-On")
                    }
                }
                
                Section(header: Text("Contact Us")) {
                    Button(action: {
                        showEmailAlert = true
                    }) {
                        Label("Email Support", systemImage: "envelope")
                    }
                }
                
                Section(header: Text("Feedback")) {
                    Button(action: { showBugReport = true }) {
                        Label("Report a Bug", systemImage: "ladybug")
                    }
                    Button(action: { showFeatureRequest = true }) {
                        Label("Suggest a Feature", systemImage: "lightbulb")
                    }
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showBugReport) {
                FeedbackView(type: .bug)
            }
            .sheet(isPresented: $showFeatureRequest) {
                FeedbackView(type: .feature)
            }
            .alert("Email Support", isPresented: $showEmailAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Contact us via our email:\nrentzone0@gmail.com")
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
