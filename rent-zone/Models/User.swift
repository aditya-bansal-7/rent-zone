import Foundation

enum AccountProvider: String, Hashable, CaseIterable {
    case google
    case apple
    case email
}

struct User: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var location: String
    var isVerified: Bool = false
    var favouriteProducts: [UUID] = []
}

struct Account: Identifiable, Hashable {
    var id: UUID = UUID()
    let userId: UUID
    var provider: AccountProvider
    var email: String
    var passwordHash: String?
}
