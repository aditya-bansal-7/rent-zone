import Foundation

enum ChatMessageType: String, Codable {
    case text
    case image
    case location
}

struct ChatConversation: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    let participantName: String
    let participantImage: String?
    var isOnline: Bool = false
    var isVerified: Bool = false
    var hasUnread: Bool = false
    var lastMessageTime: String
    var messages: [ChatMessage] = []
    // Product context for rental inquiries
    var productContext: ChatProductContext?
}

struct ChatMessage: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    let content: String
    let isFromCurrentUser: Bool
    let timestamp: String
    var messageType: ChatMessageType = .text
    var imageUrl: String?
    var locationLat: Double?
    var locationLng: Double?
    var locationName: String?
    var productContext: ChatProductContext?
}

struct ChatProductContext: Codable, Hashable {
    let productName: String
    let productImage: String
    let pricePerDay: Double
    let needDate: String
}
