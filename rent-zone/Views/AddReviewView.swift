import SwiftUI
import PhotosUI

struct AddReviewView: View {
    let product: Product
    var onReviewSubmitted: (Review) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) var appStore

    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil
    @State private var showSuccessAnimation = false

    private var isValid: Bool {
        rating > 0 && !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Product Preview Card
                    HStack(spacing: 14) {
                        if let firstImage = product.imageURLs.first,
                           firstImage.hasPrefix("http"),
                           let url = URL(string: firstImage) {
                            AsyncImage(url: url) { phase in
                                if case .success(let image) = phase {
                                    image.resizable().scaledToFill()
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray5))
                                        .overlay(ProgressView())
                                }
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name)
                                .font(.system(size: 16, weight: .bold))
                            Text("₹\(Int(product.rentPricePerDay))/day")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)

                    // Star Rating Section
                    VStack(spacing: 12) {
                        Text("How was your experience?")
                            .font(.system(size: 18, weight: .bold))

                        Text(ratingLabel)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(rating > 0 ? ratingColor : .gray)
                            .animation(.easeInOut(duration: 0.2), value: rating)

                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        rating = star
                                    }
                                }) {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.system(size: 36))
                                        .foregroundColor(star <= rating ? ratingColor : Color(.systemGray3))
                                        .scaleEffect(star <= rating ? 1.1 : 0.95)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: rating)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)

                    // Review Text Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Write your review")
                            .font(.system(size: 16, weight: .bold))

                        ZStack(alignment: .topLeading) {
                            if reviewText.isEmpty {
                                Text("Share your experience about the fabric quality, fit, comfort, and overall rental experience...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                            }

                            TextEditor(text: $reviewText)
                                .font(.system(size: 14))
                                .padding(12)
                                .frame(minHeight: 120)
                                .scrollContentBackground(.hidden)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(14)

                        HStack {
                            Spacer()
                            Text("\(reviewText.count)/500")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(reviewText.count > 500 ? .red : .gray)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)

                    // Photo Upload Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Add Photos")
                                .font(.system(size: 16, weight: .bold))
                            Text("(Optional)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                        }

                        Text("Share photos of the outfit to help other renters")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Add Photo Button
                                PhotosPicker(
                                    selection: $selectedPhotos,
                                    maxSelectionCount: 5,
                                    matching: .images
                                ) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(red: 130/255, green: 90/255, blue: 210/255))
                                        Text("\(selectedImages.count)/5")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(
                                                style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                                            )
                                            .foregroundColor(Color(red: 130/255, green: 90/255, blue: 210/255).opacity(0.4))
                                    )
                                }
                                .onChange(of: selectedPhotos) { _, newItems in
                                    Task {
                                        selectedImages = []
                                        for item in newItems {
                                            if let data = try? await item.loadTransferable(type: Data.self),
                                               let uiImage = UIImage(data: data) {
                                                selectedImages.append(uiImage)
                                            }
                                        }
                                    }
                                }

                                // Selected Image Previews
                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))

                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedImages.remove(at: index)
                                                if index < selectedPhotos.count {
                                                    selectedPhotos.remove(at: index)
                                                }
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundStyle(.white, .red)
                                                .shadow(radius: 2)
                                        }
                                        .offset(x: 6, y: -6)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)

                    // Error Message
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                    }

                    // Submit Button
                    Button(action: { Task { await submitReview() } }) {
                        ZStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else if showSuccessAnimation {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Review Submitted!")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 16))
                                    Text("Submit Review")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: isValid
                                    ? [Color(red: 130/255, green: 90/255, blue: 210/255),
                                       Color(red: 170/255, green: 120/255, blue: 240/255)]
                                    : [Color(.systemGray4), Color(.systemGray3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(
                            color: isValid
                                ? Color(red: 130/255, green: 90/255, blue: 210/255).opacity(0.35)
                                : .clear,
                            radius: 12, x: 0, y: 6
                        )
                    }
                    .disabled(!isValid || isSubmitting || showSuccessAnimation)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(white: 0.97).ignoresSafeArea())
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var ratingLabel: String {
        switch rating {
        case 1: return "😞 Poor"
        case 2: return "😐 Fair"
        case 3: return "🙂 Good"
        case 4: return "😊 Very Good"
        case 5: return "🤩 Excellent!"
        default: return "Tap a star to rate"
        }
    }

    private var ratingColor: Color {
        switch rating {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return Color(red: 0.4, green: 0.75, blue: 0.2)
        case 5: return Color(red: 130/255, green: 90/255, blue: 210/255)
        default: return .gray
        }
    }

    // MARK: - Submit

    private func submitReview() async {
        guard isValid else { return }
        guard appStore.userStore.currentUser != nil else {
            errorMessage = "Please sign in to submit a review"
            return
        }

        isSubmitting = true
        errorMessage = nil

        do {
            let review = try await ReviewService.shared.createReview(
                productId: product.id,
                rating: rating,
                content: reviewText.trimmingCharacters(in: .whitespacesAndNewlines),
                images: selectedImages
            )

            await MainActor.run {
                isSubmitting = false
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showSuccessAnimation = true
                }
            }

            // Wait a bit to show success, then dismiss
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                onReviewSubmitted(review)
                dismiss()
            }
        } catch {
            await MainActor.run {
                isSubmitting = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
