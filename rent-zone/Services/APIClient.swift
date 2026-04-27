import Foundation

// MARK: - Base URL
enum API {
    // Change this to your server IP/URL when running on a physical device
    static let baseURL = "http://localhost:3000/api"
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .decodingError(let e): return "Decoding error: \(e.localizedDescription)"
        case .serverError(let msg): return msg
        case .unauthorized: return "Unauthorized. Please log in again."
        case .noData: return "No data received from server"
        }
    }
}

// MARK: - API Response Wrapper
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T?
}

// MARK: - API Client
class APIClient {
    static let shared = APIClient()
    private init() {}

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        authenticated: Bool = false
    ) async throws -> T {
        guard let url = URL(string: API.baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authenticated {
            if let token = TokenStorage.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        if httpResponse.statusCode == 401 {
            // Try to refresh token
            if authenticated {
                do {
                    try await AuthService.shared.refreshTokens()
                    // Retry with new token
                    return try await self.request(endpoint: endpoint, method: method, body: body, authenticated: authenticated)
                } catch {
                    throw APIError.unauthorized
                }
            }
            throw APIError.unauthorized
        }

        let wrapper = try decoder.decode(APIResponse<T>.self, from: data)

        if !wrapper.success {
            throw APIError.serverError(wrapper.message ?? "Unknown server error")
        }

        guard let result = wrapper.data else {
            throw APIError.noData
        }

        return result
    }

    // MARK: Multipart Upload
    func uploadImages(
        endpoint: String,
        imageDatas: [Data],
        fieldName: String = "images"
    ) async throws -> [String] {
        guard let url = URL(string: API.baseURL + endpoint) else {
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
            bodyData.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            bodyData.append(imageData)
            bodyData.append("\r\n".data(using: .utf8)!)
        }
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = bodyData

        let (data, _) = try await URLSession.shared.data(for: request)
        let wrapper = try decoder.decode(APIResponse<ProductDTO>.self, from: data)

        guard wrapper.success, let product = wrapper.data else {
            throw APIError.serverError(wrapper.message ?? "Upload failed")
        }

        return product.imageURLs
    }
}

// MARK: - Token Storage (Keychain-backed via UserDefaults for simplicity)
class TokenStorage {
    private static let accessKey = "rz_access_token"
    private static let refreshKey = "rz_refresh_token"
    private static let userIdKey = "rz_user_id"

    static var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessKey) }
        set { UserDefaults.standard.set(newValue, forKey: accessKey) }
    }

    static var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshKey) }
        set { UserDefaults.standard.set(newValue, forKey: refreshKey) }
    }

    static var userId: String? {
        get { UserDefaults.standard.string(forKey: userIdKey) }
        set { UserDefaults.standard.set(newValue, forKey: userIdKey) }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: accessKey)
        UserDefaults.standard.removeObject(forKey: refreshKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }

    static var isLoggedIn: Bool { accessToken != nil }
}
