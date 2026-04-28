import SwiftUI
import Observation

@Observable
class AppStore {
    var userStore = UserStore()
    var productStore = ProductStore()
    var categoryStore = CategoryStore()
    var rentalStore = RentalStore()
    var reviewStore = ReviewStore()
    var notificationStore = NotificationStore()
    
    var activeTab: Int = 0
    var selectedChatConversation: ChatConversation? = nil

    init() {
        // Kick off async fetch on init
        Task {
            await fetchInitialData()
        }
    }

    func fetchInitialData() async {
        // Fetch in parallel
        async let cats: () = categoryStore.fetchItems()
        async let prods: () = productStore.fetchItems()
        _ = await (cats, prods)

        // Only fetch authenticated data if logged in
        if TokenStorage.isLoggedIn {
            await userStore.fetchCurrentUser()
            async let notifs: () = notificationStore.fetchItems()
            async let rentals: () = rentalStore.fetchItems()
            _ = await (notifs, rentals)
        }
    }

    func refreshAfterLogin() async {
        await userStore.fetchCurrentUser()
        await notificationStore.fetchItems()
        await rentalStore.fetchItems()
    }
}
