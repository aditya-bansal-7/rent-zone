import Foundation
import Observation
import UIKit

// MARK: - User Store
@Observable
class UserStore {
    var users: [User] = []
    var currentUser: User? = nil
    var isLoading: Bool = false
    var error: String? = nil

    func fetchCurrentUser() async {
        guard TokenStorage.isLoggedIn else { return }
        isLoading = true
        do {
            let dto = try await AuthService.shared.getCurrentUser()
            await MainActor.run {
                self.currentUser = dto.toUser()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func login(email: String, password: String) async throws -> User {
        let dto = try await AuthService.shared.login(email: email, password: password)
        let user = dto.toUser()
        await MainActor.run {
            self.currentUser = user
        }
        return user
    }

    func register(name: String, email: String, password: String, location: String, university: String? = nil, phoneNumber: String? = nil, preferredCategory: String? = nil) async throws -> User {
        let dto = try await AuthService.shared.register(
            name: name,
            email: email,
            password: password,
            location: location,
            university: university,
            phoneNumber: phoneNumber,
            preferredCategory: preferredCategory
        )
        let user = dto.toUser()
        await MainActor.run {
            self.currentUser = user
        }
        return user
    }

    func updateProfile(name: String, location: String, university: String? = nil, phoneNumber: String? = nil, preferredCategory: String? = nil) async throws -> User {
        let dto = try await AuthService.shared.updateProfile(
            name: name,
            location: location,
            university: university,
            phoneNumber: phoneNumber,
            preferredCategory: preferredCategory
        )
        let user = dto.toUser()
        await MainActor.run {
            self.currentUser = user
        }
        return user
    }

    func uploadProfileImage(image: UIImage) async throws {
        let dto = try await AuthService.shared.uploadProfileImage(image: image)
        let user = dto.toUser()
        await MainActor.run {
            self.currentUser = user
        }
    }

    func logout() async {
        try? await AuthService.shared.logout()
        await MainActor.run {
            self.currentUser = nil
            TokenStorage.clear()
        }
    }
}

// MARK: - Product Store
@Observable
class ProductStore {
    var products: [Product] = []
    var myProducts: [Product] = []
    var favoriteProducts: [Product] = []
    var isLoading: Bool = false
    var error: String? = nil

    func fetchItems() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await ProductService.shared.getProducts(limit: 50)
            await MainActor.run {
                self.products = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func fetchMyItems() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await ProductService.shared.getMyProducts()
            await MainActor.run {
                self.myProducts = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func fetchFavorites() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await ProductService.shared.getFavoriteProducts()
            await MainActor.run {
                self.favoriteProducts = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func toggleFavorite(productId: String, userStore: UserStore) async {
        do {
            let result = try await ProductService.shared.toggleFavorite(productId: productId)
            await MainActor.run {
                if var user = userStore.currentUser {
                    user.favouriteProducts = result.favoriteIds
                    userStore.currentUser = user
                }
                
                // Refresh favorites list if we are on favorites page
                if !result.isFavorited {
                    self.favoriteProducts.removeAll { $0.id == productId }
                }
            }
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }

    func fetchProductsByCategory(categoryId: String) async -> [Product] {
        do {
            return try await ProductService.shared.getProducts(categoryId: categoryId, limit: 50)
        } catch {
            return []
        }
    }

    func addItem(_ product: Product) {
        products.insert(product, at: 0)
    }

    func removeItem(id: String) {
        products.removeAll { $0.id == id }
        myProducts.removeAll { $0.id == id }
    }

    func updateItem(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
        }
        if let index = myProducts.firstIndex(where: { $0.id == product.id }) {
            myProducts[index] = product
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

        // Filter by occasion
        if !selectedOccasions.isEmpty {
            result = result.filter { product in
                guard let occasion = product.occasion else { return false }
                return selectedOccasions.contains(where: { $0.rawValue == occasion })
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
                break
            }
        }

        return result
    }
}

// MARK: - Category Store
@Observable
class CategoryStore {
    var categories: [Category] = []
    var isLoading: Bool = false

    func fetchItems() async {
        isLoading = true
        do {
            let fetched = try await CategoryService.shared.getCategories()
            await MainActor.run {
                self.categories = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                // Fallback to local defaults if API fails
                self.categories = Self.defaultCategories()
                self.isLoading = false
            }
        }
    }

    private static func defaultCategories() -> [Category] {
        [
            Category(id: "women-dresses", name: "Dresses", images: "Dress", type: .women),
            Category(id: "women-suits", name: "Suits", images: "Suits", type: .women),
            Category(id: "women-saree", name: "Saree", images: "Saree", type: .women),
            Category(id: "women-lehenga", name: "Lehenga", images: "Lehanga", type: .women),
            Category(id: "women-formals", name: "Formals", images: "Formal", type: .women),
            Category(id: "women-sharara", name: "Sharara", images: "Sharara", type: .women),
            Category(id: "men-tuxedos", name: "Tuxedos", images: "Tuxedo", type: .men),
            Category(id: "men-jackets", name: "Jackets", images: "Jackets", type: .men),
            Category(id: "men-blazers", name: "Blazers", images: "Blazers", type: .men),
            Category(id: "men-formals", name: "Formals", images: "Formals", type: .men),
            Category(id: "men-kurta", name: "Kurta", images: "Kurta", type: .men),
        ]
    }
}
