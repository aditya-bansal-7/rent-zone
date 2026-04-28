import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) var appStore
    
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var university: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var photoPickerItem: PhotosPickerItem? = nil
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    
    private var user: User? { appStore.userStore.currentUser }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Picture") {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let imageURL = user?.profileImage, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                            
                            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                                Text("Change Photo")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                
                Section("Personal Information") {
                    TextField("Full Name", text: $name)
                    TextField("Location", text: $location)
                    TextField("University", text: $university)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if let successMessage {
                    Section {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: handleSave) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                if let user {
                    name = user.name
                    location = user.location
                    university = user.university ?? ""
                    phoneNumber = user.phoneNumber ?? ""
                }
            }
            .onChange(of: photoPickerItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
        }
    }
    
    private func handleSave() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                // 1. Upload photo if changed
                if let selectedImage {
                    try await appStore.userStore.uploadProfileImage(image: selectedImage)
                }
                
                // 2. Update profile data
                _ = try await appStore.userStore.updateProfile(
                    name: name,
                    location: location,
                    university: university.isEmpty ? nil : university,
                    phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber
                )
                
                await MainActor.run {
                    isLoading = false
                    successMessage = "Profile updated successfully!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environment(AppStore())
}
