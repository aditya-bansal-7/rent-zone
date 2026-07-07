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


    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
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
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .frame(height: 220)
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
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 220)
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
                            .foregroundColor(product.rating > 0 ? .orange : Color(.systemGray4))

                        Text(
                            product.rating > 0 ?
                            product.rating.formatted(.number.precision(.fractionLength(0...1))) : "0"
                        )
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(product.rating > 0 ? .primary : .secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Placeholder View
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 220)
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
