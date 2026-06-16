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
    var notifications: [AppNotification] = [] {
        didSet { _refreshUnread() }
    }
    var isLoading: Bool = false
    var hasUnread: Bool = false

    var unreadNotifications: [AppNotification] {
        notifications.filter { !$0.isRead }
    }

    private func _refreshUnread() {
        hasUnread = notifications.contains { !$0.isRead }
    }

    init() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NewAppNotification"), object: nil, queue: .main) { [weak self] notification in
            if let appNotif = notification.object as? AppNotification {
                self?.addItem(appNotif)
            }
        }
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
        _refreshUnread()
    }

    func removeItem(id: String) {
        notifications.removeAll { $0.id == id }
        _refreshUnread()
    }

    func updateItem(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = notification
        }
        _refreshUnread()
    }

    func markRead(id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
        _refreshUnread()
        Task {
            try? await NotificationService.shared.markRead(id: id)
        }
    }

    func markAllRead() {
        for index in notifications.indices {
            if !notifications[index].isRead {
                let id = notifications[index].id
                notifications[index].isRead = true
                Task { try? await NotificationService.shared.markRead(id: id) }
            }
        }
        _refreshUnread()
    }

    func acceptRequest(id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].status = .accepted
            notifications[index].isRead = true
        }
        _refreshUnread()
        Task {
            try? await NotificationService.shared.respondToRentalRequest(notificationId: id, accept: true)
        }
    }

    func rejectRequest(id: String) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].status = .rejected
            notifications[index].isRead = true
        }
        _refreshUnread()
        Task {
            try? await NotificationService.shared.respondToRentalRequest(notificationId: id, accept: false)
        }
    }
}
