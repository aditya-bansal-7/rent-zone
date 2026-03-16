import Foundation

struct AppNotification: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let userId: UUID
    var title: String
    var content: String
    var icon: String
    let createdAt: Date
    var isRead: Bool
}
