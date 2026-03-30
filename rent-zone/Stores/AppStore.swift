import SwiftUI
import Combine

class AppStore: ObservableObject {
    @Published var userStore = UserStore()
    @Published var productStore = ProductStore()
    @Published var categoryStore = CategoryStore()
    @Published var rentalStore = RentalStore()
    @Published var reviewStore = ReviewStore()
    @Published var notificationStore = NotificationStore()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Forward child store changes to AppStore observers
        notificationStore.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        rentalStore.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        productStore.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        userStore.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
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
