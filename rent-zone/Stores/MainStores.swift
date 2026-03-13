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

        self.products = []
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
}

class CategoryStore: ObservableObject {
    @Published var categories: [Category] = []
    
    func fetchItems() {
        self.categories = [
            Category(name: "Men", type: .men),
            Category(name: "Women", type: .women)
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
