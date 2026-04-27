import Foundation

enum AccountProvider: String, Hashable, CaseIterable {
    case google
    case apple
    case email
}

struct User: Identifiable, Hashable {
    var id: String
    var name: String
    var location: String
    var isVerified: Bool = false
    var favouriteProducts: [String] = []
    var profileImage: String? = nil
    var email: String? = nil
}

struct Account: Identifiable, Hashable {
    var id: String
    let userId: String
    var provider: AccountProvider
    var email: String
    var passwordHash: String?
}
