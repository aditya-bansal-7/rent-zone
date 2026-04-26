import Foundation
import Observation

// MARK: - Rental Store
@Observable
class RentalStore {
    var rentals: [Rental] = []
    var isLoading: Bool = false

    func fetchItems() async {
        guard TokenStorage.isLoggedIn else { return }
        isLoading = true
        do {
            let fetched = try await RentalService.shared.getMyRentals()
            await MainActor.run {
                self.rentals = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    func addItem(_ rental: Rental) {
        rentals.append(rental)
    }

    func removeItem(id: String) {
        rentals.removeAll { $0.id == id }
    }

    func updateItem(_ rental: Rental) {
        if let index = rentals.firstIndex(where: { $0.id == rental.id }) {
            rentals[index] = rental
        }
    }
}

// MARK: - Review Store
@Observable
class ReviewStore {
    var reviews: [Review] = []

    func fetchItems() async {
        // Reviews are typically loaded per-product in ProductDetailView
    }

    func addItem(_ review: Review) {
        reviews.append(review)
    }

    func removeItem(id: String) {
        reviews.removeAll { $0.id == id }
    }

    func updateItem(_ review: Review) {
        if let index = reviews.firstIndex(where: { $0.id == review.id }) {
            reviews[index] = review
        }
    }
}

// MARK: - Notification Store
@Observable
class NotificationStore {
    var notifications: [AppNotification] = []
    var isLoading: Bool = false

    var unreadNotifications: [AppNotification] {
        notifications.filter { !$0.isRead }
    }

    var hasUnread: Bool {
        !unreadNotifications.isEmpty
    }

    func fetchItems() async {
        guard TokenStorage.isLoggedIn else { return }
        isLoading = true
        do {
            let fetched = try await NotificationService.shared.getNotifications()
            await MainActor.run {
                self.notifications = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    func addItem(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
    }

    func removeItem(id: String) {
        notifications.removeAll { $0.id == id }
    }

    func updateItem(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = notification
        }
    }

    func markRead(id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
        Task {
            try? await NotificationService.shared.markRead(id: id)
        }
    }

    func acceptRequest(id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].status = .accepted
            notifications[index].isRead = true
        }
        Task {
            try? await NotificationService.shared.respondToRentalRequest(notificationId: id, accept: true)
        }
    }

    func rejectRequest(id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].status = .rejected
            notifications[index].isRead = true
        }
        Task {
            try? await NotificationService.shared.respondToRentalRequest(notificationId: id, accept: false)
        }
    }
}
