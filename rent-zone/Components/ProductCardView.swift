import SwiftUI

struct ProductCardView: View {
    @Environment(AppStore.self) var appStore
    let product: Product
    @Binding var favoriteProductIds: Set<String>

    var isFavorite: Bool {
        favoriteProductIds.contains(product.id)
    }

    var imageURL: String? {
        product.imageURLs.first
    }

    // Responsive card width for 2-column grid
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width / 2 - 24
    }

    var body: some View {
        NavigationLink(value: product) {
            VStack(alignment: .leading, spacing: 8) {

                // MARK: - Image Section
                ZStack(alignment: .topTrailing) {

                    if let urlStr = imageURL,
                       let url = URL(string: urlStr),
                       urlStr.hasPrefix("http") {

                        AsyncImage(url: url) { phase in
                            switch phase {

                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: cardWidth, height: 220)
                                    .clipped()
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )

                            case .failure(_), .empty:
                                placeholderView

                            @unknown default:
                                placeholderView
                            }
                        }

                    } else if let localName = imageURL {

                        Image(localName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cardWidth, height: 220)
                            .clipped()
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )

                    } else {
                        placeholderView
                    }

                    // MARK: - Favorite Button
                    Button {
                        toggleFavorite()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 30, height: 30)
                                .shadow(
                                    color: .black.opacity(0.12),
                                    radius: 3,
                                    x: 0,
                                    y: 2
                                )

                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(isFavorite ? .red : .gray)
                        }
                    }
                    .padding(8)
                }

                // MARK: - Product Name
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                // MARK: - Price + Rating
                HStack {
                    Text("₹ \(Int(product.rentPricePerDay))/day")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()

                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)

                        Text(
                            product.rating.formatted(
                                .number.precision(.fractionLength(0...1))
                            )
                        )
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    }
                }
            }
            .frame(width: cardWidth, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Placeholder View
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(width: cardWidth, height: 220)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            )
    }

    // MARK: - Favorite Toggle
    private func toggleFavorite() {
        // Immediate UI feedback
        if isFavorite {
            favoriteProductIds.remove(product.id)
        } else {
            favoriteProductIds.insert(product.id)
        }
        
        // Sync with backend
        Task {
            await appStore.productStore.toggleFavorite(productId: product.id, userStore: appStore.userStore)
            
            // Ensure local state matches store just in case
            await MainActor.run {
                if let favorites = appStore.userStore.currentUser?.favouriteProducts {
                    favoriteProductIds = Set(favorites)
                }
            }
        }
    }
}
