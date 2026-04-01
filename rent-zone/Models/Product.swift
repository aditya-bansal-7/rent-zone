import Foundation
import UIKit

enum ProductCondition: String, Hashable, CaseIterable {
    case new
    case likeNew = "Like New"
    case good
    case worn
}

enum DescriptionTypes: String, Hashable, CaseIterable{
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
    var uploadedImages: [UIImage] = []
    var reviews: [Review] = []
    var rating: Double = 0.0
    var isPopular: Bool = false
}

struct Category: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var images: String
    var type: CategoryType
}

