import SwiftUI

struct ListingInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) var appStore
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemGray6).opacity(0.3)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Profile Header
                    profileHeader
                    
                    // MARK: - Stats Bar
                    statsBar
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // MARK: - Product Grid
                    listingGrid
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image("profile_photo")
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            Text("Payal Singh")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Greater Noida")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
    
    // MARK: - Stats Bar
    private var statsBar: some View {
        HStack(spacing: 0) {
            statItem(count: 7, label: "RENTALS")
            
            Divider()
                .frame(height: 36)
            
            statItem(count: appStore.productStore.products.count, label: "LISTINGS")
            
            Divider()
                .frame(height: 36)
            
            statItem(count: 9, label: "REVIEWS")
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func statItem(count: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Listing Grid
    private var listingGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ]
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(appStore.productStore.products) { product in
                ListingCardView(product: product)
            }
        }
    }
}

// MARK: - Listing Card View
struct ListingCardView: View {
    let product: Product
    @State private var isEditSheetPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Image with edit button
            ZStack(alignment: .topTrailing) {
                // Show uploaded image or asset image
                Group {
                        Image(product.imageURLs.first ?? "")
                            .resizable()
                            .scaledToFill()

                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
                
                // Edit button
                Button(action: { isEditSheetPresented = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(8)
            }
            
            // Product name
            Text(product.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // Price
            Text("₹ \(Int(product.rentPricePerDay))/day")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .sheet(isPresented: $isEditSheetPresented) {
            ProductDetailEditView(product: product)
        }
    }
}

#Preview {
    ListingInfoView()
        .environment(AppStore())
}
