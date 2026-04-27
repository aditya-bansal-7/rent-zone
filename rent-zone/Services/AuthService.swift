import Foundation

// MARK: - Auth DTOs
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let location: String
}

struct AuthResponse: Decodable {
    let user: UserDTO
    let accessToken: String
    let refreshToken: String
}

struct RefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Auth Service
class AuthService {
    static let shared = AuthService()
    private init() {}

    // MARK: Login
    func login(email: String, password: String) async throws -> UserDTO {
        let body: [String: Any] = ["email": email, "password": password]
        let result: AuthResponse = try await APIClient.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: body
        )
        TokenStorage.accessToken = result.accessToken
        TokenStorage.refreshToken = result.refreshToken
        TokenStorage.userId = result.user.id
        return result.user
    }

    // MARK: Register
    func register(name: String, email: String, password: String, location: String, university: String? = nil, phoneNumber: String? = nil, preferredCategory: String? = nil) async throws -> UserDTO {
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "location": location,
            "university": university as Any,
            "phoneNumber": phoneNumber as Any,
            "preferredCategory": preferredCategory as Any
        ]
        let result: AuthResponse = try await APIClient.shared.request(
            endpoint: "/auth/register",
            method: "POST",
            body: body
        )
        TokenStorage.accessToken = result.accessToken
        TokenStorage.refreshToken = result.refreshToken
        TokenStorage.userId = result.user.id
        return result.user
    }

    // MARK: Refresh Tokens
    func refreshTokens() async throws {
        guard let refreshToken = TokenStorage.refreshToken else {
            throw APIError.unauthorized
        }
        let body: [String: Any] = ["refreshToken": refreshToken]
        let result: RefreshResponse = try await APIClient.shared.request(
            endpoint: "/auth/refresh",
            method: "POST",
            body: body
        )
        TokenStorage.accessToken = result.accessToken
        TokenStorage.refreshToken = result.refreshToken
    }

    // MARK: Logout
    func logout() async throws {
        try await APIClient.shared.request(
            endpoint: "/auth/logout",
            method: "POST",
            body: nil,
            authenticated: true
        ) as EmptyResponse
        TokenStorage.clear()
    }

    // MARK: Get Current User
    func getCurrentUser() async throws -> UserDTO {
        return try await APIClient.shared.request(
            endpoint: "/auth/me",
            authenticated: true
        )
    }
}

// MARK: - Empty Response helper
struct EmptyResponse: Decodable {}
