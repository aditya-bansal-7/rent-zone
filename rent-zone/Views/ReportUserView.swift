import SwiftUI

struct ReportUserView: View {
    
    @Environment(AppStore.self) var appStore
    
    let reportedUserName: String
    let reportedUserImage: String?
    let reportedUserLocation: String?
    
    @State private var selectedReason = "Choose report reasons"
    @State private var description = ""
    @State private var showSuccess = false
    @Environment(\.dismiss) private var dismiss
    
    let reasons = ["Choose report reasons", "Fraud", "Spam", "Fake Profile", "Abusive Behaviour"]
    
    var isFormValid: Bool {
        selectedReason != "Choose report reasons" && !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Profile Image
                    if let imgStr = reportedUserImage, let url = URL(string: imgStr), imgStr.hasPrefix("http") {
                        AsyncImage(url: url) { phase in
                            if case .success(let image) = phase {
                                image.resizable().scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill").foregroundColor(.gray.opacity(0.5))
                            }
                        }
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    } else if let imgStr = reportedUserImage {
                        Image(imgStr)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .foregroundColor(.gray.opacity(0.5))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    }
                    
                    // Name
                    Text(reportedUserName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let location = reportedUserLocation {
                        Text(location)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Warning Section
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading) {
                                Text("Report a User")
                                    .font(.headline)
                                
                                Text("Report users who are engaged in fraudulent activity.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        
                        // Report Reason
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Report Reason")
                                .font(.title2)
                                .bold()
                            
                            Picker("Choose report reasons", selection: $selectedReason) {
                                ForEach(reasons, id: \.self) { reason in
                                    Text(reason).tag(reason)
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                        }
                        
                        
                        // Description
                        VStack(alignment: .leading) {
                            Text("Describe The Issue")
                                .font(.headline)
                            
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.08), radius: 4)
                        }
                        
                        
                        // Submit Button
                        Button {
                            showSuccess = true
                        } label: {
                            Text("Submit Report")
                                .foregroundColor(isFormValid ? .black : .gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color(red: 243/255, green: 236/255, blue: 255/255) : Color(.systemGray5))
                                .cornerRadius(30)
                        }
                        .disabled(!isFormValid)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                    
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .alert("Report Submitted Successfully", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for reporting. We will review the report and take appropriate action.")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.black)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Report User")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ReportUserView(reportedUserName: "Aditya Bansal", reportedUserImage: nil, reportedUserLocation: "New Delhi")
        .environment(AppStore())
}
