import SwiftUI

struct OtherUserProfileView: View {
    let user: User
    let userId: String
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    @State private var userProducts: [Product] = []
    @State private var isLoading = true
    @State private var favoriteProductIds: Set<String> = []
    
    var body: some View {
        ZStack {
            Color(white: 0.98).edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Profile Header
                    VStack(spacing: 12) {
                        if let imageURL = user.profileImage, let url = URL(string: imageURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure(_), .empty:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundStyle(.gray)
                                @unknown default:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundStyle(.gray)
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundStyle(.gray)
                        }
                        
                        if user.isVerified == true {
                            Label("Verified", systemImage: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                        
                        Text(user.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if !user.location.isEmpty {
                            Label(user.location, systemImage: "mappin.and.ellipse")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                    
                    // User Listings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(user.name)'s Listings")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 150)
                        } else if userProducts.isEmpty {
                            Text("No listings found.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 100)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
                                ForEach(userProducts) { product in
                                    NavigationLink(destination: ProductDetailView(product: product).environment(appStore)) {
                                        ProductCardView(product: product, favoriteProductIds: $favoriteProductIds)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let user = appStore.userStore.currentUser {
                favoriteProductIds = Set(user.favouriteProducts)
            }
            Task {
                do {
                    userProducts = try await ProductService.shared.getProducts(listedByUserId: userId)
                    isLoading = false
                } catch {
                    print("Error fetching user products: \(error)")
                    isLoading = false
                }
            }
        }
    }
}
