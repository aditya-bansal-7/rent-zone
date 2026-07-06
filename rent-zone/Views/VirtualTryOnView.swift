import SwiftUI
import PhotosUI

struct VirtualTryOnView: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var uploadedImage: UIImage? = nil
    @State private var isProcessing = false
    @State private var showNoPhotoError = false
    @State private var showResult = false
    @State private var resultImageURL: String? = nil
    @State private var errorMessage: String? = nil
    @State private var processingStage: String = "Uploading your photo..."
    @State private var showInfoSheet = false

    // Brand colors
    private let accentPurple = Color.brandPurple
    private let lightPurple = Color.brandPurple.opacity(0.10)
    private let mediumPurple = Color.brandPurple.opacity(0.18)

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer(minLength: 16)

                // MARK: - Photo Upload Area
                photoUploadSection
                    .padding(.horizontal, 20)

                // MARK: - Error Message
                if let errorMessage {
                    errorBanner(errorMessage)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }

                Spacer(minLength: 16)

                // MARK: - How It Works
                howItWorksSection
                    .padding(.horizontal, 20)

                Spacer(minLength: 16)

                // MARK: - Tips for Best Results
                tipsSection
                    .padding(.horizontal, 20)

                Spacer(minLength: 16)

                // MARK: - Bottom CTA (inline, not overlay)
                bottomCTASection
            }

            // Processing overlay
            if isProcessing {
                processingOverlay
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isProcessing)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    uploadedImage = image
                    errorMessage = nil
                }
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            if let resultImageURL {
                TryOnResultView(product: product, resultImageURL: resultImageURL)
                    .environment(appStore)
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            infoSheetContent
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background {
                        Group {
                            if #available(iOS 26.0, *) {
                                Color.clear
                            } else {
                                Circle()
                                    .fill(Color(UIColor.secondarySystemBackground))
                            }
                        }
                    }
                    .if26GlassEffect(cornerRadius: 22)
                    .clipShape(Circle())
            }

            Spacer()

            Text("Virtual Try-On")
                .font(.system(size: 22, weight: .bold))

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
    }

    // MARK: - Photo Upload Section
    private var photoUploadSection: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            ZStack {
                // Dashed border container
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                accentPurple.opacity(0.04),
                                accentPurple.opacity(0.08),
                                accentPurple.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [10, 8])
                            )
                            .foregroundColor(accentPurple.opacity(0.35))
                    )

                if let uploadedImage {
                    // Show uploaded image
                    Image(uiImage: uploadedImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(20)
                        .overlay(alignment: .bottomTrailing) {
                            // Change photo badge
                            HStack(spacing: 6) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12))
                                Text("Change")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(accentPurple)
                            .clipShape(Capsule())
                            .padding(24)
                        }
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(accentPurple.opacity(0.08))
                                .frame(width: 72, height: 72)

                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(accentPurple.opacity(0.6))
                        }

                        Text("Upload a full-body photo to try on outfits")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxHeight: 260)
        }
    }

    // MARK: - Error Banner
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 14))
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.red.opacity(0.8))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.red.opacity(0.06))
        )
    }

    // MARK: - How It Works Section
    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("How It Works")
                .font(.system(size: 20, weight: .bold))

            HStack(spacing: 0) {
                stepColumn(
                    number: "1",
                    icon: "camera.fill",
                    title: "Upload Photo",
                    subtitle: "Upload a clear\nfull-body photo"
                )

                stepColumn(
                    number: "2",
                    icon: "wand.and.stars",
                    title: "AI Processing",
                    subtitle: "Our AI fits the outfit\nto your body"
                )

                stepColumn(
                    number: "3",
                    icon: "tshirt.fill",
                    title: "See The Result",
                    subtitle: "View your look from\nmultiple angles"
                )
            }
        }
    }

    private func stepColumn(number: String, icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(lightPurple)
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primary)
                    }

            }

            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tips for Best Results")
                .font(.system(size: 18, weight: .bold))

            HStack(alignment: .center, spacing: 16) {
                // Tips list
                VStack(alignment: .leading, spacing: 14) {
                    tipRow(icon: "figure.stand", text: "Stand straight in a well-lit area")
                    tipRow(icon: "person.fill", text: "Make sure your full body is visible")
                    tipRow(icon: "camera.metering.none", text: "Avoid blurry or dark photos")
                }

                Spacer()

                // Body silhouette illustration
                Image("BodySilhouette")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .padding(.trailing, 4)
            }
        }
        .padding(20)
        .background {
            Group {
                if #available(iOS 26.0, *) {
                    Color.clear
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemBackground))
                }
            }
        }
        .if26GlassEffect(cornerRadius: 20)
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(accentPurple)
                .frame(width: 24, height: 24)

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Bottom CTA Section
    private var bottomCTASection: some View {
        VStack(spacing: 10) {
            Button {
                if let image = uploadedImage {
                    Task { await performTryOn(with: image) }
                } else {
                    withAnimation { showNoPhotoError = true }
                }
            } label: {
                Text("Try This Outfit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.brandPurple)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 20)

            // Inline hint shown when tapping without photo
            if showNoPhotoError {
                Text("Please upload a photo first")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.orange)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { showNoPhotoError = false }
                        }
                    }
            }
        }
        .padding(.horizontal, 0)
        .padding(.bottom, 8)
    }

    // MARK: - Processing Overlay
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                Text(processingStage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("This usually takes 30–60 seconds")
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

    // MARK: - Info Sheet
    private var infoSheetContent: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How Virtual Try-On Works")
                        .font(.system(size: 22, weight: .bold))

                    Text("Our AI-powered virtual try-on lets you see how an outfit looks on your body before renting it.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 16) {
                        infoItem(icon: "camera.fill", title: "Upload a Photo", description: "Take or upload a clear, full-body photo of yourself standing straight.")
                        infoItem(icon: "wand.and.stars", title: "AI Processing", description: "Our AI analyzes your body shape and fits the selected outfit onto your photo.")
                        infoItem(icon: "tshirt.fill", title: "See Results", description: "View the result showing how the outfit would look on you.")
                        infoItem(icon: "lock.shield.fill", title: "Privacy", description: "Your photos are processed securely and are not shared with anyone.")
                    }
                }
                .padding(24)
            }
            .navigationTitle("About Try-On")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { showInfoSheet = false }
                        .foregroundColor(.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func infoItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.primary)
                .frame(width: 36, height: 36)
                .background(Color.primary.opacity(0.10))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Perform Try-On (Real API Call)
    private func performTryOn(with personImage: UIImage) async {
        await MainActor.run {
            withAnimation {
                isProcessing = true
                processingStage = "Uploading your photo..."
                errorMessage = nil
            }
        }

        // Animate through processing stages that match the real backend workflow:
        // 1. Upload person photo → Cloudinary (~2s)
        // 2. Upload both images to YCE → file_ids (~4s)
        // 3. Submit & poll YCE try-on task (~15-20s)
        // 4. Upload result → Cloudinary, save to DB (~3s)
        Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            await MainActor.run {
                if isProcessing { processingStage = "Preparing images for AI..." }
            }
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            await MainActor.run {
                if isProcessing { processingStage = "AI is fitting the garment..." }
            }
            try? await Task.sleep(nanoseconds: 12_000_000_000)
            await MainActor.run {
                if isProcessing { processingStage = "Finalising your look..." }
            }
        }

        do {
            let result = try await TryOnService.shared.submitTryOn(
                productId: product.id,
                personImage: personImage
            )

            await MainActor.run {
                withAnimation {
                    isProcessing = false
                }
                resultImageURL = result.resultImageURL
                showResult = true
                if let model = result.modelUsed {
                    print("[TryOn] Model used: \(model)")
                }
            }
        } catch {
            await MainActor.run {
                withAnimation {
                    isProcessing = false
                }
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Dashed Line Shape
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
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
