import Foundation

enum SortOption: String, CaseIterable {
    case priceLowToHigh = "Price: Low to High"
    case priceHighToLow = "Price: High to Low"
    case ratingHighToLow = "Rating: High to Low"
    case newest = "Newest First"
}

enum ClothingSize: String, CaseIterable {
    case xs = "XS"
    case s = "S"
    case m = "M"
    case l = "L"
    case xl = "XL"
}

enum Occasion: String, CaseIterable {
    case wedding = "Wedding"
    case party = "Party"
    case festival = "Festival"
    case casual = "Casual"
    case formal = "Formal"
}
