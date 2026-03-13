import SwiftUI
import Combine

class AppStore: ObservableObject {
    var objectWillChange: ObservableObjectPublisher

    @Published var userStore = UserStore()
    @Published var productStore = ProductStore()
    @Published var categoryStore = CategoryStore()
    @Published var rentalStore = RentalStore()
    @Published var reviewStore = ReviewStore()
    @Published var notificationStore = NotificationStore()
    
    
    init() {
        fetchInitialData()
    }
    
    func fetchInitialData() {
        userStore.fetchItems()
        productStore.fetchItems()
        categoryStore.fetchItems()
        rentalStore.fetchItems()
        reviewStore.fetchItems()
        notificationStore.fetchItems()
    }
}
