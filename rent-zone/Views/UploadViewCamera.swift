import SwiftUI
import PhotosUI

struct UploadViewCamera: View {

    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var currentPage = 0
    @State private var isLoggedInRequired = false
    @State private var navigateToUpload = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 2) {
                    Text("Upload Photos")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical,8)
                Spacer()

                // Show selected images in slider or default illustration
                if selectedImages.isEmpty {
                    Image("upload_photo_illustration")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 400, maxHeight: 480)
                        .padding(.horizontal, 16)
                } else {
                    TabView(selection: $currentPage) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 320, maxHeight: 400)
                                .clipped()
                                .cornerRadius(16)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 420)
                    .padding(.horizontal, 16)
                }

                Spacer().frame(height: 30)

                // Upload Photo button
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                        Text(selectedImages.isEmpty ? "Upload Photo" : "Edit Photos")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 70)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                    )
                }

                Spacer().frame(height: 20)

                if selectedImages.isEmpty {
                    Text("Upload clear, attractive photos\nof your outfit to attract renters.")
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Spacer().frame(height: 30)

                // Next button — only shown when images are selected
                if !selectedImages.isEmpty {
                    Button(action: {
                        if TokenStorage.isLoggedIn {
                            navigateToUpload = true
                        } else {
                            isLoggedInRequired = true
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.brandPurple)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal, 40)
                    .navigationDestination(isPresented: $navigateToUpload) {
                        UploadView(selectedImages: selectedImages)
                    }
                }

                Spacer().frame(height: 40)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isLoggedInRequired) {
                LoginView()
                    .presentationDetents([.fraction(0.85), .large])
            }
            .onChange(of: selectedItems) { _, newItems in
                Task {
                    var images: [UIImage] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            images.append(image)
                        }
                    }
                    selectedImages = images
                    currentPage = 0
                }
            }
        }
    }
}

#Preview {
    UploadViewCamera()
        .environment(AppStore())
}
