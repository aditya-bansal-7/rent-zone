import SwiftUI

struct ProductGridView: View {
    let products: [Product]
    @Binding var favoriteProductIds: Set<String>
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(products) { product in
                ProductCardView(product: product, favoriteProductIds: $favoriteProductIds)
            }
        }
    }
}
