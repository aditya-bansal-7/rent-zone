import Foundation

struct User: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var location: String
    var isVerified: Bool
    var favoriteProductIDs: [UUID]
}

struct Account: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let userId: UUID
    var provider: AccountProvider
    var email: String
    var passwordHash: String?
}
