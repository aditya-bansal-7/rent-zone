import Foundation

struct Review: Identifiable, Hashable {
    var id: UUID = UUID()
    let productId: UUID
    let userId: UUID
    var rating: Int
    var content: String
    var imageURLs: [String]
    let createdAt: Date
}
