import SwiftUI
import Observation

@Observable class AppStore {
    var userStore = UserStore()
    var productStore = ProductStore()
    var categoryStore = CategoryStore()
    var rentalStore = RentalStore()
    var reviewStore = ReviewStore()
    var notificationStore = NotificationStore()
    
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
