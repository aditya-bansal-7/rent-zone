import SwiftUI

struct TryOnResultView: View {
    let product: Product
    let resultImageURL: String
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Header
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
                                                .fill(.ultraThinMaterial)
                                        }
                                    }
                                }
                                .if26GlassEffect(cornerRadius: 22)
                                .clipShape(Circle())
                        }

                        Spacer()

                        Text("Try-On Result")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)

                        Spacer()

                        // Invisible spacer to center title
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // MARK: - Result Image
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            if !resultImageURL.isEmpty, let url = URL(string: resultImageURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                                            .transition(.opacity.combined(with: .scale(scale: 0.95)))

                                    case .failure:
                                        VStack(spacing: 16) {
                                            Image(systemName: "exclamationmark.triangle")
                                                .font(.system(size: 40))
                                                .foregroundColor(.orange)
                                            Text("Failed to load image")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Text("The try-on result is saved. You can view it in your try-on history.")
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 400)
                                        .background(
                                            RoundedRectangle(cornerRadius: 24)
                                                .fill(Color(.systemGray6))
                                        )

                                    case .empty:
                                        VStack(spacing: 20) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                                .scaleEffect(1.5)
                                            Text("Loading your try-on result...")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 400)
                                        .background(
                                            RoundedRectangle(cornerRadius: 24)
                                                .fill(Color(.systemGray6))
                                        )

                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .animation(.easeInOut(duration: 0.3), value: resultImageURL)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            } else {
                                VStack(spacing: 20) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(1.5)
                                    Text("Preparing result...")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 400)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            }

                            // MARK: - View Outfit Details Button
                            NavigationLink(destination: ProductDetailView(product: product).environment(appStore)) {
                                HStack(spacing: 8) {
                                    Text("View Details")
                                        .font(.system(size: 17, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.brandPurple)
                                .clipShape(Capsule())
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    TryOnResultView(
        product: Product(
            id: "preview",
            name: "Sharara",
            rentPricePerDay: 400,
            securityDeposit: 500,
            condition: .new,
            size: "M",
            description: [:],
            bookedDates: [],
            listedByUserId: "user1",
            categoryId: "cat1",
            pickupLocation: "Jaipur",
            imageURLs: ["https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80"],
            rating: 4.5
        ),
        resultImageURL: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80"
    )
    .environment(AppStore())
}
