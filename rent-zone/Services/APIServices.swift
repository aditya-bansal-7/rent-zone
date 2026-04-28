import Foundation
import UIKit

// MARK: - Product Service
class ProductService {
    static let shared = ProductService()
    private init() {}

    // MARK: Get All Products (with optional filters)
    func getProducts(
        categoryId: String? = nil,
        size: String? = nil,
        condition: String? = nil,
        occasion: String? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        sort: String? = nil,
        page: Int = 1,
        limit: Int = 50
    ) async throws -> [Product] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
        if let categoryId { queryItems.append(URLQueryItem(name: "categoryId", value: categoryId)) }
        if let size { queryItems.append(URLQueryItem(name: "size", value: size)) }
        if let condition { queryItems.append(URLQueryItem(name: "condition", value: condition)) }
        if let occasion { queryItems.append(URLQueryItem(name: "occasion", value: occasion)) }
        if let minPrice { queryItems.append(URLQueryItem(name: "minPrice", value: "\(minPrice)")) }
        if let maxPrice { queryItems.append(URLQueryItem(name: "maxPrice", value: "\(maxPrice)")) }
        if let sort { queryItems.append(URLQueryItem(name: "sort", value: sort)) }

        var components = URLComponents(string: API.baseURL + "/products")!
        components.queryItems = queryItems
        let endpoint = (components.url?.absoluteString.replacingOccurrences(of: API.baseURL, with: "")) ?? "/products"

        let result: PaginatedProducts = try await APIClient.shared.request(endpoint: endpoint)
        return result.products.map { $0.toProduct() }
    }

    // MARK: Get Product By ID
    func getProduct(id: String) async throws -> Product {
        let dto: ProductDTO = try await APIClient.shared.request(endpoint: "/products/\(id)")
        return dto.toProduct()
    }

    func getMyProducts() async throws -> [Product] {
        let result: [ProductDTO] = try await APIClient.shared.request(
            endpoint: "/products/mine/all",
            authenticated: true
        )
        return result.map { $0.toProduct() }
    }

    // MARK: Create Product
    func createProduct(
        name: String,
        rentPricePerDay: Double,
        securityDeposit: Double,
        condition: String,
        size: String,
        categoryId: String,
        pickupLocation: String,
        occasion: String? = nil,
        description: [String: String] = [:]
    ) async throws -> Product {
        var body: [String: Any] = [
            "name": name,
            "rentPricePerDay": rentPricePerDay,
            "securityDeposit": securityDeposit,
            "condition": condition,
            "size": size,
            "categoryId": categoryId,
            "pickupLocation": pickupLocation,
            "description": description
        ]
        if let occasion { body["occasion"] = occasion }

        let dto: ProductDTO = try await APIClient.shared.request(
            endpoint: "/products",
            method: "POST",
            body: body,
            authenticated: true
        )
        return dto.toProduct()
    }

    func updateProduct(id: String, body: [String: Any]) async throws -> Product {
        let dto: ProductDTO = try await APIClient.shared.request(
            endpoint: "/products/\(id)",
            method: "PATCH",
            body: body,
            authenticated: true
        )
        return dto.toProduct()
    }

    func deleteProduct(id: String) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/products/\(id)",
            method: "DELETE",
            authenticated: true
        )
    }

    // MARK: Upload Images to product
    func uploadImages(productId: String, images: [UIImage]) async throws -> Product {
        let imageDatas = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
        guard !imageDatas.isEmpty else { throw APIError.noData }

        guard let url = URL(string: API.baseURL + "/products/\(productId)/images") else {
            throw APIError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = TokenStorage.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var bodyData = Data()
        for (index, imageData) in imageDatas.enumerated() {
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            bodyData.append(imageData)
            bodyData.append("\r\n".data(using: .utf8)!)
        }
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = bodyData

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let (data, _) = try await URLSession.shared.data(for: request)
        let wrapper = try decoder.decode(APIResponse<ProductDTO>.self, from: data)

        guard wrapper.success, let dto = wrapper.data else {
            throw APIError.serverError(wrapper.message ?? "Upload failed")
        }

        return dto.toProduct()
    }

    // MARK: Get Booked Dates
    func getBookedDates(productId: String) async throws -> [Date] {
        let dateStrings: [String] = try await APIClient.shared.request(endpoint: "/products/\(productId)/booked-dates")
        let formatter = ISO8601DateFormatter()
        return dateStrings.compactMap { formatter.date(from: $0) }
    }

    func toggleFavorite(productId: String) async throws -> (isFavorited: Bool, favoriteIds: [String]) {
        struct FavoriteResponse: Decodable {
            let isFavorited: Bool
            let favoriteIds: [String]
        }
        
        let result: FavoriteResponse = try await APIClient.shared.request(
            endpoint: "/products/\(productId)/favorite",
            method: "POST",
            authenticated: true
        )
        return (result.isFavorited, result.favoriteIds)
    }

    func getFavoriteProducts() async throws -> [Product] {
        let dtos: [ProductDTO] = try await APIClient.shared.request(
            endpoint: "/products/mine/favorites",
            authenticated: true
        )
        return dtos.map { $0.toProduct() }
    }
}

// MARK: - Category Service
class CategoryService {
    static let shared = CategoryService()
    private init() {}

    func getCategories(type: String? = nil) async throws -> [Category] {
        var endpoint = "/categories"
        if let type = type { endpoint += "?type=\(type)" }
        let dtos: [CategoryDTO] = try await APIClient.shared.request(endpoint: endpoint)
        return dtos.map { $0.toCategory() }
    }
}

// MARK: - Rental Service
class RentalService {
    static let shared = RentalService()
    private init() {}

    func createRental(productId: String, startDate: Date, endDate: Date) async throws -> Rental {
        let formatter = ISO8601DateFormatter()
        let body: [String: Any] = [
            "productId": productId,
            "startDate": formatter.string(from: startDate),
            "endDate": formatter.string(from: endDate)
        ]
        let dto: RentalDTO = try await APIClient.shared.request(
            endpoint: "/rentals",
            method: "POST",
            body: body,
            authenticated: true
        )
        return dto.toRental()
    }

    func getMyRentals() async throws -> [Rental] {
        let dtos: [RentalDTO] = try await APIClient.shared.request(
            endpoint: "/rentals/mine",
            authenticated: true
        )
        return dtos.map { $0.toRental() }
    }

    func updateRentalStatus(rentalId: String, status: String) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/rentals/\(rentalId)/status",
            method: "PATCH",
            body: ["status": status],
            authenticated: true
        )
    }
}

// MARK: - Review Service
class ReviewService {
    static let shared = ReviewService()
    private init() {}

    /// Create a review with optional images (multipart form data)
    func createReview(
        productId: String,
        rating: Int,
        content: String,
        images: [UIImage] = []
    ) async throws -> Review {
        guard let url = URL(string: API.baseURL + "/reviews") else {
            throw APIError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = TokenStorage.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw APIError.unauthorized
        }

        var bodyData = Data()

        // Add productId field
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"productId\"\r\n\r\n".data(using: .utf8)!)
        bodyData.append("\(productId)\r\n".data(using: .utf8)!)

        // Add rating field
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"rating\"\r\n\r\n".data(using: .utf8)!)
        bodyData.append("\(rating)\r\n".data(using: .utf8)!)

        // Add content field
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"content\"\r\n\r\n".data(using: .utf8)!)
        bodyData.append("\(content)\r\n".data(using: .utf8)!)

        // Add image files
        let imageDatas = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
        for (index, imageData) in imageDatas.enumerated() {
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"images\"; filename=\"review\(index).jpg\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            bodyData.append(imageData)
            bodyData.append("\r\n".data(using: .utf8)!)
        }

        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = bodyData

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let (data, _) = try await URLSession.shared.data(for: request)
        let wrapper = try decoder.decode(APIResponse<ReviewDTO>.self, from: data)

        guard wrapper.success, let dto = wrapper.data else {
            throw APIError.serverError(wrapper.message ?? "Failed to submit review")
        }

        return dto.toReview()
    }

    /// Get all reviews for a product
    func getProductReviews(productId: String) async throws -> [Review] {
        let dtos: [ReviewDTO] = try await APIClient.shared.request(
            endpoint: "/reviews/product/\(productId)"
        )
        return dtos.map { $0.toReview() }
    }

    /// Delete a review
    func deleteReview(id: String) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/reviews/\(id)",
            method: "DELETE",
            authenticated: true
        )
    }
}

// MARK: - Notification Service
class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func getNotifications() async throws -> [AppNotification] {
        let dtos: [NotificationDTO] = try await APIClient.shared.request(
            endpoint: "/notifications",
            authenticated: true
        )
        return dtos.map { $0.toNotification() }
    }

    func markRead(id: String) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/notifications/\(id)/read",
            method: "PATCH",
            authenticated: true
        )
    }

    func respondToRentalRequest(notificationId: String, accept: Bool) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/notifications/\(notificationId)/\(accept ? "accept" : "reject")",
            method: "POST",
            authenticated: true
        )
    }
}
