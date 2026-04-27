import Foundation

struct Report: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let reportedByUserId: String
    let reportedUserId: String
    var reason: String
    var description: String
    var isValid: Bool
}
