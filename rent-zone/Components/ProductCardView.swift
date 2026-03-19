import SwiftUI

struct ProductCardView: View {
    let product: Product
    @Binding var favoriteProductIds: Set<UUID>
    
    var body: some View {
        let isFavorite = favoriteProductIds.contains(product.id)
        return NavigationLink(destination: ProductDetailView(product: product)) {
            VStack(alignment: .leading, spacing: 6) {
                // Image area
            ZStack(alignment: .topTrailing) {
                Image(product.imageURLs.first ?? "")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
                
                // Favorite button
                Button(action: {
                    if isFavorite {
                        favoriteProductIds.remove(product.id)
                    } else {
                        favoriteProductIds.insert(product.id)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 13))
                            .foregroundColor(isFavorite ? .red : .gray)
                    }
                }
                .padding(8)
            }
            
            // Product name
            Text(product.name)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
            
            // Price and rating
            HStack {
                Text("₹ \(Int(product.rentPricePerDay))/day")
                    .font(.system(size: 12, weight: .semibold))
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    
                    Text(product.rating.formatted(.number.precision(.fractionLength(0...1))))
                        .font(.system(size: 12, weight: .medium))
                }
            }
            }
        }
        .buttonStyle(.plain)
    }
}

