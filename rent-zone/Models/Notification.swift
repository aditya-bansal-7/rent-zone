import Foundation

enum NotificationType: String, Hashable {
    case rentalRequest
    case general
}

enum NotificationStatus: String, Hashable {
    case pending
    case accepted
    case rejected
}

struct AppNotification: Identifiable, Hashable {
    var id: String
    let userId: String
    var title: String
    var content: String
    var icon: String
    let createdAt: Date
    var isRead: Bool
    var type: NotificationType = .general
    var status: NotificationStatus = .pending
    var productId: String?
    var fromUserId: String?
    var rentalDate: Date?
    var totalPrice: Double?
    var productImageName: String?
    var productName: String?
    var requesterName: String?
}
