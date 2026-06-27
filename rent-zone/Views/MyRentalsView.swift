import SwiftUI

// MARK: - Rental Tab Enum
enum RentalTab: String, CaseIterable {
    case rented = "Rented"
    case lentOut = "Lent Out"
}

struct MyRentalsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) var appStore

    @State private var selectedTab: RentalTab = .rented
    @State private var hasFetched = false
    @State private var productCache: [String: Product] = [:]
    @State private var isFetchingProducts = false
    @State private var productToReview: Product?

    private var user: User? { appStore.userStore.currentUser }

    // Outfits I rented from someone else
    private var rentedItems: [Rental] {
        guard let userId = user?.id else { return [] }
        return appStore.rentalStore.rentals.filter { $0.rentedByUserId == userId }
    }

    // Outfits I lent out to someone else
    private var lentOutItems: [Rental] {
        guard let userId = user?.id else { return [] }
        return appStore.rentalStore.rentals.filter { $0.rentedFromUserId == userId }
    }

    private var currentItems: [Rental] {
        selectedTab == .rented ? rentedItems : lentOutItems
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Segmented Picker (like Categories)
                    Picker("Rental Type", selection: $selectedTab) {
                        ForEach(RentalTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    // MARK: - Content
                    if appStore.rentalStore.isLoading && appStore.rentalStore.rentals.isEmpty {
                        Spacer()
                        ProgressView("Loading rentals...")
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    } else if currentItems.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView(showsIndicators: false) {
                            // MARK: - Rental Cards
                            LazyVStack(spacing: 14) {
                                ForEach(currentItems) { rental in
                                    RentalCardView(
                                        rental: rental,
                                        product: productCache[rental.productId],
                                        isLentOut: selectedTab == .lentOut,
                                        onReviewTap: {
                                            if let product = productCache[rental.productId] {
                                                productToReview = product
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("My Rentals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButton(action: { dismiss() })
                }
            }
            .task {
                guard !hasFetched else { return }
                hasFetched = true
                await appStore.rentalStore.fetchItems()
                await fetchProductDetails()
            }
            .onChange(of: appStore.rentalStore.rentals) { _, _ in
                Task {
                    await fetchProductDetails()
                }
            }
            .sheet(item: $productToReview) { product in
                AddReviewView(product: product) { _ in
                    // Currently no local review state needed in MyRentalsView
                }
                .environment(appStore)
            }
        }
    }


    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: selectedTab == .rented ? "bag" : "tray.full")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.gray.opacity(0.6), .gray.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(selectedTab == .rented ? "No Rentals Yet" : "No Items Lent Out")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            Text(selectedTab == .rented
                 ? "Outfits you rent will appear here."
                 : "Outfits you lend to others will show up here.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Fetch Product Details
    private func fetchProductDetails() async {
        guard !isFetchingProducts else { return }
        isFetchingProducts = true
        let allProductIds = Set(appStore.rentalStore.rentals.map { $0.productId })
        let missingIds = allProductIds.filter { productCache[$0] == nil }

        for productId in missingIds {
            do {
                let product = try await ProductService.shared.getProduct(id: productId)
                await MainActor.run {
                    productCache[productId] = product
                }
            } catch {
                print("Failed to fetch product \(productId): \(error)")
            }
        }
        await MainActor.run {
            isFetchingProducts = false
        }
    }
}

// MARK: - Rental Card View
struct RentalCardView: View {
    let rental: Rental
    let product: Product?
    let isLentOut: Bool
    var onReviewTap: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Product Image
                productImage
                    .frame(width: 90, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Details
                VStack(alignment: .leading, spacing: 6) {
                    // Product name
                    Text(product?.name ?? "Loading...")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    // Date range
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text("\(formattedDate(rental.startDate)) – \(formattedDate(rental.endDate))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    // Price
                    Text("₹ \(Int(rental.totalPrice))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)

                    // Status Badge
                    statusBadge
                }

                Spacer()
            }
            .padding(12)

            if !isLentOut {
                Divider()
                
                Button(action: {
                    onReviewTap?()
                }) {
                    HStack {
                        Text("How was your experience?")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 11))
                            Text("Write a Review")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.brandPurple)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Product Image
    @ViewBuilder
    private var productImage: some View {
        if let imageURL = product?.imageURLs.first, let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    imagePlaceholder
                }
            }
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
            )
    }

    // MARK: - Status Badge
    private var statusBadge: some View {
        let (text, color) = statusInfo
        return Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }

    private var statusInfo: (String, Color) {
        switch rental.status {
        case .requested:
            return ("Requested", .orange)
        case .approved:
            return ("Approved", .blue)
        case .active:
            return ("Active", .green)
        case .returned:
            return ("Returned", .gray)
        case .cancelled:
            return ("Cancelled", .red)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    MyRentalsView()
        .environment(AppStore())
}
