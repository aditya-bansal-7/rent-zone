import Foundation


enum RentalStatus: String, Codable, Hashable, CaseIterable {
    case requested
    case approved
    case active
    case returned
    case cancelled
}


struct Rental: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let productId: UUID
    let rentedByUserId: UUID
    let rentedFromUserId: UUID
    var startDate: Date
    var endDate: Date
    var totalPrice: Double
    var status: RentalStatus
}
