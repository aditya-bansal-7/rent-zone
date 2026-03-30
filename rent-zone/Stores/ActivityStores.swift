import Foundation
import Combine

class RentalStore: ObservableObject {
    @Published var rentals: [Rental] = []
    
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

class ReviewStore: ObservableObject {
    @Published var reviews: [Review] = []
    
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

class NotificationStore: ObservableObject {
    @Published var notifications: [AppNotification] = []
    
    var unreadNotifications: [AppNotification] {
        notifications.filter { !$0.isRead }
    }
    
    var hasUnread: Bool {
        !unreadNotifications.isEmpty
    }
    
    func fetchItems() {
        let now = Date()
        
        self.notifications = [
            AppNotification(
                userId: UUID(),
                title: "New Rental Request",
                content: "A user wants to rent your \"Rajasthani Poshak\".",
                icon: "bell.fill",
                createdAt: now.addingTimeInterval(-2 * 3600),
                isRead: false,
                type: .rentalRequest,
                status: .pending,
                rentalDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 24)),
                totalPrice: 520,
                productImageName: "rajasthani_poshak",
                productName: "Rajasthani Poshak",
                requesterName: "Shreya Singh"
            ),
            AppNotification(
                userId: UUID(),
                title: "New Rental Request",
                content: "A user wants to rent your \"Rajasthani Poshak\".",
                icon: "bell.fill",
                createdAt: now.addingTimeInterval(-5 * 3600),
                isRead: true,
                type: .rentalRequest,
                status: .rejected,
                rentalDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 24)),
                totalPrice: 520,
                productImageName: "rajasthani_poshak",
                productName: "Rajasthani Poshak",
                requesterName: "Kirtika Kandari"
            ),
            AppNotification(
                userId: UUID(),
                title: "New Rental Request",
                content: "A user wants to rent your \"Rajasthani Poshak\".",
                icon: "bell.fill",
                createdAt: now.addingTimeInterval(-24 * 3600),
                isRead: true,
                type: .rentalRequest,
                status: .accepted,
                rentalDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 24)),
                totalPrice: 520,
                productImageName: "sharara_orange",
                productName: "Rajasthani Poshak",
                requesterName: "Payal Singh"
            )
        ]
    }
    
    func addItem(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
    }
    
    func removeItem(id: UUID) {
        notifications.removeAll { $0.id == id }
    }
    
    func updateItem(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = notification
        }
    }
    
    func acceptRequest(id: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].status = .accepted
            notifications[index].isRead = true
        }
    }
    
    func rejectRequest(id: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].status = .rejected
            notifications[index].isRead = true
        }
    }
    
    func sendRentalRequest(product: Product, fromUserName: String) {
        let notification = AppNotification(
            userId: product.listedByUserId,
            title: "New Rental Request",
            content: "A user wants to rent your \"\(product.name)\".",
            icon: "bell.fill",
            createdAt: Date(),
            isRead: false,
            type: .rentalRequest,
            status: .pending,
            productId: product.id,
            rentalDate: Date(),
            totalPrice: product.rentPricePerDay,
            productImageName: product.imageURLs.first,
            productName: product.name,
            requesterName: fromUserName
        )
        addItem(notification)
    }
}
