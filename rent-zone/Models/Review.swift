import Foundation

struct Review: Identifiable, Hashable {
    var id: String
    let productId: String
    let userId: String
    var rating: Int
    var content: String
    var imageURLs: [String]
    var userName: String?
    var userImage: String?
}
