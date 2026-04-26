import Foundation

struct Rental: Identifiable, Hashable {
    var id: String
    let productId: String
    let rentedByUserId: String
    let rentedFromUserId: String
    var startDate: Date
    var endDate: Date
    var totalPrice: Double
    var status: RentalStatus
}

enum RentalStatus: String, Hashable, CaseIterable {
    case requested
    case approved
    case active
    case returned
    case cancelled
}
