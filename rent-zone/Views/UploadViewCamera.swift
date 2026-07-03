import SwiftUI
import PhotosUI

extension Color {
    static let purpleAccent = Color(red: 124/255, green: 77/255, blue: 255/255)
}

struct UploadViewCamera: View {

    @Environment(AppStore.self) var appStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isLoggedInRequired = false
    @State private var navigateToUpload = false
    @State private var showInfoSheet = false

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
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        if selectedImages.isEmpty {
                            // Upload dashed container
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.purpleAccent.opacity(0.1))
                                        .frame(width: 72, height: 72)
                                    
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(.purpleAccent)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("Upload Outfit Photos")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Add up to 6 high-quality photos.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                PhotosPicker(selection: $selectedItems, maxSelectionCount: 6, matching: .images) {
                                    Text("Choose Photos")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 200, height: 52)
                                        .background(Color.purpleAccent)
                                        .clipShape(Capsule())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.purpleAccent.opacity(0.03))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                                    .foregroundColor(Color.purpleAccent.opacity(0.3))
                            )
                            .padding(.horizontal, 20)
                        } else {
                            // Grid of selected images with delete buttons and Add More tile
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Selected Photos (\(selectedImages.count)/6)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                    ForEach(selectedImages.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: selectedImages[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .frame(height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                                )
                                            
                                            Button(action: {
                                                selectedImages.remove(at: index)
                                                if index < selectedItems.count {
                                                    selectedItems.remove(at: index)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 22))
                                                    .foregroundColor(.red)
                                                    .background(Circle().fill(Color.white))
                                                    .padding(4)
                                            }
                                        }
                                    }
                                    
                                    if selectedImages.count < 6 {
                                        PhotosPicker(selection: $selectedItems, maxSelectionCount: 6, matching: .images) {
                                            VStack(spacing: 8) {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 20, weight: .semibold))
                                                    .foregroundColor(.purpleAccent)
                                                Text("Add More")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.purpleAccent)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 100)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(Color.purpleAccent.opacity(0.03))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                                    .foregroundColor(Color.purpleAccent.opacity(0.3))
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Photo Guide Grid Section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Photo Guide")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Follow these examples for the best listing photos.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                                ForEach(guideCards) { card in
                                    GuideCardView(card: card)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                    }
                    .padding(.bottom, 24)
                }
                .background(Color(red: 242/255, green: 242/255, blue: 247/255))
                
                // Sticky Bottom Button Container
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.black.opacity(0.08))
                    
                    Button(action: {
                        if TokenStorage.isLoggedIn {
                            navigateToUpload = true
                        } else {
                            isLoggedInRequired = true
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(selectedImages.isEmpty ? .secondary : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(selectedImages.isEmpty ? Color(uiColor: .systemGray5) : Color.purpleAccent)
                            .clipShape(Capsule())
                    }
                    .disabled(selectedImages.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                }
                .background(Color(uiColor: .systemBackground))
            }
            .navigationDestination(isPresented: $navigateToUpload) {
                UploadView(selectedImages: selectedImages)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isLoggedInRequired) {
                LoginView()
                    .presentationDetents([.fraction(0.85), .large])
            }
            .sheet(isPresented: $showInfoSheet) {
                TipsModalView(isPresented: $showInfoSheet)
            }
            .toolbar(.hidden, for: .navigationBar) // Hide standard nav bar to use custom top items and clear overlaps
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
                }
            }
        }
    }
}

// MARK: - Guide Cards UI Support

struct GuideCard: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let caption: String
    let isGood: Bool
}

private let guideCards = [
    GuideCard(imageName: "guide_full_outfit", title: "Full Outfit", caption: "Show the entire outfit from head to toe.", isGood: true),
    GuideCard(imageName: "guide_show_details", title: "Show Details", caption: "Capture embroidery, texture and fabric quality.", isGood: true),
    GuideCard(imageName: "guide_good_lighting", title: "Good Lighting", caption: "Take photos in natural daylight.", isGood: true),
    GuideCard(imageName: "guide_poor_lighting", title: "Poor Lighting", caption: "Avoid dark or blurry images.", isGood: false),
    GuideCard(imageName: "guide_cluttered_bg", title: "Cluttered Background", caption: "Use a plain and tidy background.", isGood: false),
    GuideCard(imageName: "guide_cropped_outfit", title: "Cropped Outfit", caption: "Capture the complete outfit.", isGood: false)
]

struct GuideCardView: View {
    let card: GuideCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with overlay
            ZStack(alignment: .topLeading) {
                Image(card.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipped()
                
                // Badge overlay
                Image(systemName: card.isGood ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 24))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, card.isGood ? Color.green : Color.red)
                    .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                    .padding(8)
            }
            .frame(height: 120)
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(card.caption)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 32, alignment: .topLeading)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 184)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Tips Modal UI Support

struct TipsModalView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Quality photos help your outfit stand out and attract more renters.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        TipRow(icon: "sun.max.fill", title: "Bright Natural Light", description: "Shoot near a large window or outdoors to show true colors and details.")
                        
                        TipRow(icon: "house.fill", title: "Clean Background", description: "Keep the background free from clutter or mess so the focus remains on the outfit.")
                        
                        TipRow(icon: "camera.fill", title: "Capture the Details", description: "Close-ups of embroidery, fabric texture, and tags help build renter confidence.")
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Photo Tips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.purpleAccent)
                }
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.purpleAccent)
                .frame(width: 32, height: 32)
                .background(Color.purpleAccent.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    UploadViewCamera()
        .environment(AppStore())
}
