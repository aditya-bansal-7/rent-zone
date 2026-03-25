import Foundation

struct ChatConversation: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
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
    var id: UUID = UUID()
    let content: String
    let isFromCurrentUser: Bool
    let timestamp: String
}

struct ChatProductContext: Codable, Hashable {
    let productName: String
    let productImage: String
    let pricePerDay: Double
    let needDate: String
}
