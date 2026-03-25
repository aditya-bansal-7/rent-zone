import SwiftUI

struct ReportUserView: View {
    
    @Environment(AppStore.self) var appStore
    
    @State private var selectedReason = "Choose report reasons"
    @State private var description = ""
    @Environment(\.dismiss) private var dismiss
    
    let reasons = ["Choose report reasons", "Fraud", "Spam", "Fake Profile", "Abusive Behaviour"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Profile Image
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .foregroundColor(.gray.opacity(0.5))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                    
                    // Name
                    Text("Shreya Singh")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Greater Noida")
                        .foregroundColor(.gray)
                    
                    
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
                            print("Report Submitted")
                        } label: {
                            Text("Submit Report")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 243/255, green: 236/255, blue: 255/255))
                                .cornerRadius(30)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                    
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
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
    ReportUserView()
        .environment(AppStore())
}
