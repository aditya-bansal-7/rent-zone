import Foundation

enum ProductCondition: String, Hashable, CaseIterable {
    case new
    case likeNew
    case good
    case worn
}

enum DescriptionTypes: String, Hashable, CaseIterable {
    case fabric
    case brand
    case style
    case fitAndComfort
}

enum CategoryType: String, Hashable, CaseIterable {
    case men
    case women
}

struct Product: Identifiable, Hashable {
    var id: String
    var name: String
    var rentPricePerDay: Double
    var securityDeposit: Double
    var condition: ProductCondition
    var size: String
    var description: [DescriptionTypes: String] = [:]
    var bookedDates: [Date] = []
    var listedByUserId: String
    var listedBy: ListedByDTO?
    var categoryId: String
    var pickupLocation: String
    var imageURLs: [String]
    var reviews: [Review] = []
    var rating: Double = 0.0
    var occasion: String? = nil
}

struct Category: Identifiable, Hashable {
    var id: String
    var name: String
    var images: String
    var type: CategoryType
}
