import Foundation

struct VirtualTryOn: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let userId: String
    let productId: String
    var resultImageURL: String
}
