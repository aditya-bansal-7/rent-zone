import Foundation
import Observation

@Observable class RentalStore {
    var rentals: [Rental] = []
    
    func fetchItems() {
        self.rentals = []
    }
    
    func addItem(_ rental: Rental) {
        rentals.append(rental)
    }
    
    func removeItem(id: UUID) {
        rentals.removeAll { $0.id == id }
    }
    
    func updateItem(_ rental: Rental) {
        if let index = rentals.firstIndex(where: { $0.id == rental.id }) {
            rentals[index] = rental
        }
    }
}

@Observable class ReviewStore {
    var reviews: [Review] = []
    
    func fetchItems() {
        self.reviews = []
    }
    
    func addItem(_ review: Review) {
        reviews.append(review)
    }
    
    func removeItem(id: UUID) {
        reviews.removeAll { $0.id == id }
    }
    
    func updateItem(_ review: Review) {
        if let index = reviews.firstIndex(where: { $0.id == review.id }) {
            reviews[index] = review
        }
    }
}

@Observable class NotificationStore {
    var notifications: [AppNotification] = []
    
    func fetchItems() {
        self.notifications = []
    }
    
    func addItem(_ notification: AppNotification) {
        notifications.append(notification)
    }
    
    func removeItem(id: UUID) {
        notifications.removeAll { $0.id == id }
    }
    
    func updateItem(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = notification
        }
    }
}
