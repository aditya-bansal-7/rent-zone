import SwiftUI

struct ListingInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) var appStore
    
    private var user: User? { appStore.userStore.currentUser }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGray6).opacity(0.3)
                    .ignoresSafeArea()
                
                if appStore.productStore.isLoading && appStore.productStore.myProducts.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading your listings...")
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                } else if appStore.productStore.myProducts.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No listings yet")
                            .font(.headline)
                        Text("Start listing your items to see them here!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
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
                }
            }
            .navigationTitle("My Listings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 30, height: 30)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }
            .task {
                await appStore.productStore.fetchMyItems()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            Group {
                if let imageURL = user?.profileImage, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            Text(user?.name ?? "Guest User")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            Text(user?.location ?? "Unknown Location")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Stats Bar
    private var statsBar: some View {
        HStack(spacing: 0) {
            statItem(count: 0, label: "RENTALS") // Placeholder for now
            
            Divider()
                .frame(height: 36)
            
            statItem(count: appStore.productStore.myProducts.count, label: "LISTINGS")
            
            Divider()
                .frame(height: 36)
            
            statItem(count: 0, label: "REVIEWS") // Placeholder for now
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
            ForEach(appStore.productStore.myProducts) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ListingCardView(product: product)
                }
                .buttonStyle(PlainButtonStyle())
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
                Group {
                    if let imageURL = product.imageURLs.first, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Color.gray.opacity(0.2)
                                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
                            }
                        }
                    } else {
                        Color.gray.opacity(0.2)
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    }
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
