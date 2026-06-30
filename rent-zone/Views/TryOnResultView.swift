import SwiftUI

struct TryOnResultView: View {
    let product: Product
    let resultImageURL: String
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    @State private var isSaved = false
    @State private var showProductDetail = false

    private let lavender = Color(red: 220/255, green: 208/255, blue: 255/255)

    var body: some View {
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
                        if let url = URL(string: resultImageURL) {
                            AsyncImage(url: url) { phase in
                                if case .success(let image) = phase {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                                } else if case .failure = phase {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 400)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                        )
                                } else {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 400)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .overlay(ProgressView())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        }

                        // MARK: - View Outfit Details Button
                        Button(action: {
                            showProductDetail = true
                        }) {
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
                        .fullScreenCover(isPresented: $showProductDetail) {
                            ProductDetailView(product: product)
                                .environment(appStore)
                        }

                        // MARK: - Save & Share Row
                        HStack(spacing: 16) {
                            // Save to Favourites Button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isSaved.toggle()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: isSaved ? "heart.fill" : "heart")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(isSaved ? .red : .primary)
                                    Text(isSaved ? "Saved" : "Save")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule().stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                            }

                            // Share Button
                            Button(action: {
                                shareResult()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Share")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule().stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }


    private func shareResult() {
        let shareText = "Check out how \(product.name) looks on me! 👗 via RentZone"
        
        // Use URL for sharing, optionally downloading could be added here
        var items: [Any] = [shareText]
        if let url = URL(string: resultImageURL) {
            items.append(url)
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = []

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            activityVC.popoverPresentationController?.sourceView = topVC.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.maxY - 100, width: 0, height: 0)
            topVC.present(activityVC, animated: true)
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
