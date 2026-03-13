import Foundation

enum ProductCondition: String, Codable, Hashable, CaseIterable {
    case new
    case likeNew = "Like New"
    case good
    case worn
}


enum CategoryType: String, Codable, Hashable, CaseIterable {
    case men
    case women
}

struct Product: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var rentPricePerDay: Double
    var securityDeposit: Double
    var condition: ProductCondition
    var size: String
    let listedByUserId: UUID
    var categoryId: UUID
    var pickupLocation: String
    var imageURLs: [String]
}

struct Category: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var type: CategoryType
}

