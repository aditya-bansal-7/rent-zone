import SwiftUI
import PhotosUI

struct VirtualTryOnView: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var uploadedImage: UIImage? = nil
    @State private var isProcessing = false
    @State private var tryOnPickerItem: PhotosPickerItem? = nil
    @State private var showResult = false
    @State private var resultImage: UIImage? = nil

    // Lavender accent
    private let lavender = Color(red: 220/255, green: 208/255, blue: 255/255)
    private let lavenderLight = Color(red: 243/255, green: 236/255, blue: 255/255)

    var body: some View {
        ZStack {
            Color(white: 0.97)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: - Back Button
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background {
                                    Group {
                                        if #available(iOS 26.0, *) {
                                            Color.clear
                                        } else {
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                        }
                                    }
                                }
                                .if26GlassEffect(cornerRadius: 22)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Hero Image Area
                    heroImageSection
                        .padding(.horizontal, 20)

                    // MARK: - Upload Photo Button
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Upload Photo")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background {
                            Group {
                                if #available(iOS 26.0, *) {
                                    Color.clear
                                } else {
                                    Capsule()
                                        .fill(lavender.opacity(0.6))
                                }
                            }
                        }
                        .if26GlassEffect(cornerRadius: 25)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, -8)
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                uploadedImage = image
                            }
                        }
                    }

                    // MARK: - How It Works
                    howItWorksSection
                        .padding(.horizontal, 20)

                    // MARK: - Helpful Tips
                    helpfulTipsSection
                        .padding(.horizontal, 20)

                    // MARK: - Start Try-On Button
                    PhotosPicker(selection: $tryOnPickerItem, matching: .images) {
                        Text("Start Try-On")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background {
                                Group {
                                    if #available(iOS 26.0, *) {
                                        Color.clear
                                    } else {
                                        Capsule()
                                            .fill(lavender)
                                    }
                                }
                            }
                            .if26GlassEffect(cornerRadius: 28)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                .padding(.top, 8)
            }

            // Processing overlay
            if isProcessing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("AI is processing your try-on...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("This may take a moment")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(40)
                .background {
                    Group {
                        if #available(iOS 26.0, *) {
                            Color.clear
                        } else {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                        }
                    }
                }
                .if26GlassEffect(cornerRadius: 24)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isProcessing)
        .onChange(of: tryOnPickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        withAnimation {
                            isProcessing = true
                        }
                    }

                    // Simulate AI processing delay
                    try? await Task.sleep(nanoseconds: 2_500_000_000)

                    await MainActor.run {
                        withAnimation {
                            isProcessing = false
                        }
                        resultImage = image
                        showResult = true
                        tryOnPickerItem = nil
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            if let resultImage {
                TryOnResultView(product: product, userImage: resultImage)
                    .environment(appStore)
            }
        }
    }

    // MARK: - Hero Image Section
    private var heroImageSection: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 200/255, green: 180/255, blue: 230/255).opacity(0.4),
                            Color(red: 230/255, green: 220/255, blue: 245/255).opacity(0.6),
                            Color(red: 245/255, green: 240/255, blue: 250/255).opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 320)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial.opacity(0.3))
                )

            // Sparkle decorations
            sparkleOverlay

            // Center content - uploaded image or silhouette
            if let uploadedImage {
                Image(uiImage: uploadedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                            .foregroundColor(.white.opacity(0.8))
                    )
                    .padding(20)
            } else {
                // Silhouette placeholder
                VStack(spacing: 0) {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 120, weight: .ultraLight))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.gray.opacity(0.5), .gray.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(30)
                )
            }
        }
        .frame(height: 320)
    }

    // MARK: - Sparkle Overlay
    private var sparkleOverlay: some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .offset(x: -80, y: -60)

            Image(systemName: "sparkle")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .offset(x: 90, y: -80)

            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .offset(x: -100, y: 20)

            Image(systemName: "sparkle")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .offset(x: 110, y: -10)

            Image(systemName: "sparkle")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .offset(x: -60, y: 80)

            Image(systemName: "sparkle")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .offset(x: 70, y: 70)
        }
    }

    // MARK: - How It Works
    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How It Works")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)

            stepRow(
                number: "1",
                icon: "square.and.arrow.up",
                title: "Upload Your Photo",
                subtitle: "Take or upload a full-body photo"
            )

            stepRow(
                number: "2",
                icon: "cpu",
                title: "AI Processing",
                subtitle: "AI will apply the outfit to your body"
            )

            stepRow(
                number: "3",
                icon: "arrow.triangle.2.circlepath",
                title: "Try Multiple Angles",
                subtitle: "View from different perspectives"
            )
        }
    }

    private func stepRow(number: String, icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 32, height: 32)
                .background(lavenderLight)
                .clipShape(Circle())

            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 130/255, green: 100/255, blue: 200/255))
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Helpful Tips
    private var helpfulTipsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Helpful Tips")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)

            tipRow("Position yourself fully within the frame")
            tipRow("Avoid Blurry Photos")
            tipRow("Stand Straight For Best Results")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            Group {
                if #available(iOS 26.0, *) {
                    Color.clear
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                }
            }
        }
        .if26GlassEffect(cornerRadius: 20)
    }

    private func tipRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 130/255, green: 100/255, blue: 200/255))
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
        }
    }
}


#Preview {
    VirtualTryOnView(product: Product(
        id: "preview",
        name: "Sharara",
        rentPricePerDay: 400,
        securityDeposit: 500,
        condition: .new,
        size: "M",
        listedByUserId: "user1",
        categoryId: "cat1",
        pickupLocation: "Jaipur",
        imageURLs: ["https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80"],
        rating: 4.5
    ))
}
