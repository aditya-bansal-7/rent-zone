import Foundation
import Combine

class UserStore: ObservableObject {
    @Published var users: [User] = []
    
    func fetchItems() {
        self.users = [
            User(name: "Payal Singh", location: "Mumbai", isVerified: true)
        ]
    }

    func addItem(_ user: User) {
        users.append(user)
    }
    
    func removeItem(id: UUID) {
        users.removeAll { $0.id == id }
    }
    
    func updateItem(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }
}

class ProductStore: ObservableObject {
    @Published var products: [Product] = []
    
    func fetchItems() {
        let dummyUserId = UUID()
        let dummyCategoryId = UUID()
        
        self.products = [
            Product(
                name: "Rajasthani Poshak",
                rentPricePerDay: 520,
                securityDeposit: 1000,
                condition: .good,
                size: "M",
                listedByUserId: dummyUserId,
                categoryId: dummyCategoryId,
                pickupLocation: "Mumbai",
                imageURLs: ["rajasthani_poshak"],
                rating: 4.5,
                isPopular: true
            ),
            Product(
                name: "Sharara",
                rentPricePerDay: 349,
                securityDeposit: 800,
                condition: .likeNew,
                size: "S",
                listedByUserId: dummyUserId,
                categoryId: dummyCategoryId,
                pickupLocation: "Delhi",
                imageURLs: ["sharara"],
                rating: 4.5,
                isPopular: true
            ),
            Product(
                name: "Tuxedo Black",
                rentPricePerDay: 500,
                securityDeposit: 1200,
                condition: .new,
                size: "L",
                listedByUserId: dummyUserId,
                categoryId: dummyCategoryId,
                pickupLocation: "Bangalore",
                imageURLs: ["tuxedo_black"],
                rating: 4.0,
                isPopular: true
            ),
            Product(
                name: "Sharara",
                rentPricePerDay: 400,
                securityDeposit: 900,
                condition: .good,
                size: "M",
                listedByUserId: dummyUserId,
                categoryId: dummyCategoryId,
                pickupLocation: "Jaipur",
                imageURLs: ["sharara_orange"],
                rating: 5.0,
                isPopular: true
            ),
            Product(
                name: "Modern Lehenga",
                rentPricePerDay: 249,
                securityDeposit: 700,
                condition: .likeNew,
                size: "S",
                listedByUserId: dummyUserId,
                categoryId: dummyCategoryId,
                pickupLocation: "Pune",
                imageURLs: ["modern_lehenga"],
                rating: 4.5,
                isPopular: false
            ),
            Product(
                name: "Garba Dress",
                rentPricePerDay: 249,
                securityDeposit: 600,
                condition: .good,
                size: "M",
                listedByUserId: dummyUserId,
                categoryId: dummyCategoryId,
                pickupLocation: "Ahmedabad",
                imageURLs: ["garba_dress"],
                rating: 4.3,
                isPopular: false
            )
        ]
    }
    
    func addItem(_ product: Product) {
        products.append(product)
    }
    
    func removeItem(id: UUID) {
        products.removeAll { $0.id == id }
    }
    
    func updateItem(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
        }
    }
    
    func sortedAndFiltered(
        sortOption: SortOption?,
        priceRange: ClosedRange<Double>,
        selectedSizes: Set<ClothingSize>,
        selectedOccasions: Set<Occasion>,
        selectedDate: Date?
    ) -> [Product] {
        var result = products
        
        // Filter by price range
        result = result.filter { priceRange.contains($0.rentPricePerDay) }
        
        // Filter by size
        if !selectedSizes.isEmpty {
            result = result.filter { product in
                selectedSizes.contains(where: { $0.rawValue == product.size })
            }
        }
        
        // Filter by date availability
        if let date = selectedDate {
            result = result.filter { product in
                !product.bookedDates.contains(where: {
                    Calendar.current.isDate($0, inSameDayAs: date)
                })
            }
        }
        
        // Sort
        if let sortOption = sortOption {
            switch sortOption {
            case .priceLowToHigh:
                result.sort { $0.rentPricePerDay < $1.rentPricePerDay }
            case .priceHighToLow:
                result.sort { $0.rentPricePerDay > $1.rentPricePerDay }
            case .ratingHighToLow:
                result.sort { $0.rating > $1.rating }
            case .newest:
                break // No creation date to sort by currently
            }
        }
        
        return result
    }
}

class CategoryStore: ObservableObject {
    @Published var categories: [Category] = []
    
    func fetchItems() {
        self.categories = [
            Category(name: "All Items", images: "square.grid.2x2", type: .women),
            Category(name: "Dress", images: "tshirt", type: .women),
            Category(name: "Tuxedo", images: "figure.stand", type: .men),
            Category(name: "Jewellery", images: "sparkles", type: .women)
        ]
    }
    
    func addItem(_ category: Category) {
        categories.append(category)
    }
    
    func removeItem(id: UUID) {
        categories.removeAll { $0.id == id }
    }
    
    func updateItem(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
        }
    }
}
