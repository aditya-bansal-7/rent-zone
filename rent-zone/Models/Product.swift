import Foundation

enum ProductCondition: String, Codable, Hashable, CaseIterable {
    case new
    case likeNew = "Like New"
    case good
    case worn
}

enum DescriptionTypes: String, Codable, Hashable, CaseIterable{
    case fabric
    case brand
    case style
    case fitAndComfort
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
    var description: [DescriptionTypes:String] = [:]
    var bookedDates: [Date] = []
    let listedByUserId: UUID
    var categoryId: UUID
    var pickupLocation: String
    var imageURLs: [String]
    var reviews: [Review] = []
    var rating: Double = 0.0
    var isPopular: Bool = false
}

struct Category: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var images: String
    var type: CategoryType
}

