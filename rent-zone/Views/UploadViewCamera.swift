import SwiftUI
import PhotosUI

struct UploadViewCamera: View {
    
    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [String] = []
    @State private var currentPage = 0
    
    private func saveImageToTempDirectory(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        do {
            try data.write(to: url, options: [.atomic])
            return url.path
        } catch {
            return nil
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                            if let uiImage = UIImage(contentsOfFile: selectedImages[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: 320, maxHeight: 400)
                                    .clipped()
                                    .cornerRadius(16)
                                    .tag(index)
                            } else {
                                Color.gray.opacity(0.1)
                                    .frame(maxWidth: 320, maxHeight: 400)
                                    .cornerRadius(16)
                                    .tag(index)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 420)
                    .padding(.horizontal, 16)
                }
                
                Spacer()
                    .frame(height: 30)
                
                // Upload Photo button
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                        Text(selectedImages.isEmpty ? "Upload Photo" : "Change Photos")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 70)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                    )
                }
                
                Spacer()
                    .frame(height: 20)
                
                // Description text
                Text("Upload clear, attractive photos\nof your outfit to attract renters.")
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                Spacer()
                    .frame(height: 30)
                
                // Next button navigates to UploadView with selected images
                NavigationLink(destination: UploadView(selectedImages: selectedImages)) {
                    Text("Next")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.purple.opacity(0.15))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 40)
            }
            .navigationTitle("Upload Photos")
            
            .onChange(of: selectedItems) { _, newItems in
                Task {
                    var paths: [String] = []
                    for item in newItems {
                        do {
                            if let data = try await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data),
                               let path = saveImageToTempDirectory(uiImage) {
                                paths.append(path)
                            }
                        } catch {
                            // Ignore individual failures and continue
                        }
                    }
                    selectedImages = paths
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
