import Foundation

struct VirtualTryOn: Identifiable, Hashable {
    var id: UUID = UUID()
    let userId: UUID
    let productId: UUID
    var resultImageURL: String
}
