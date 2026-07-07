import SwiftUI
import PhotosUI

enum FeedbackType {
    case bug
    case feature
    
    var title: String {
        switch self {
        case .bug: return "Report a Bug"
        case .feature: return "Suggest a Feature"
        }
    }
    
    var placeholder: String {
        switch self {
        case .bug: return "Describe the bug you encountered..."
        case .feature: return "Describe the feature you'd like to see..."
        }
    }
}

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    let type: FeedbackType
    
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 120)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text(type.placeholder)
                                        .foregroundColor(Color(.placeholderText))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section(header: Text("Attachment (Optional)")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                            .overlay(alignment: .topTrailing) {
                                Button(action: {
                                    selectedImage = nil
                                    selectedItem = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.5).clipShape(Circle()))
                                        .padding(8)
                                }
                            }
                    } else {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo")
                                Text("Add Screenshot")
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: submitFeedback) {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Submit")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                    .listRowBackground(
                        description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting
                        ? Color.gray.opacity(0.3)
                        : Color.brandPurple
                    )
                    .foregroundColor(.white)
                }
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            selectedImage = uiImage
                        }
                    }
                }
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your feedback has been sent to the admin panel. Thank you!")
            }
        }
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccessAlert = true
        }
    }
}

#Preview {
    FeedbackView(type: .bug)
}
