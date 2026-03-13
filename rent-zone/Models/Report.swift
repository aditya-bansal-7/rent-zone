import Foundation

struct Report: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let reportedByUserId: UUID
    let reportedUserId: UUID
    var reason: String
    var description: String
    var isValid: Bool
}
