import Foundation
import UIKit

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
    let isNewUser: Bool?
}

struct RefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct VerifyOtpResponse: Decodable {
    let user: UserDTO?
    let email: String?
    let accessToken: String?
    let refreshToken: String?
    let isNewUser: Bool?
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

    // MARK: Send OTP
    func sendOtp(email: String) async throws {
        let body: [String: Any] = ["email": email]
        _ = try await APIClient.shared.request(
            endpoint: "/auth/send-otp",
            method: "POST",
            body: body
        ) as EmptyResponse
    }

    // MARK: Verify OTP
    func verifyOtp(email: String, code: String) async throws -> VerifyOtpResponse {
        let body: [String: Any] = ["email": email, "code": code]
        let result: VerifyOtpResponse = try await APIClient.shared.request(
            endpoint: "/auth/verify-otp",
            method: "POST",
            body: body
        )
        
        if let accessToken = result.accessToken, let refreshToken = result.refreshToken, let user = result.user {
            TokenStorage.accessToken = accessToken
            TokenStorage.refreshToken = refreshToken
            TokenStorage.userId = user.id
        }
        
        return result
    }

    // MARK: OAuth Login
    func oauthLogin(name: String?, provider: String, idToken: String) async throws -> (user: UserDTO, isNewUser: Bool) {
        let body: [String: Any] = [
            "name": name as Any,
            "provider": provider,
            "idToken": idToken
        ]
        let result: AuthResponse = try await APIClient.shared.request(
            endpoint: "/auth/oauth",
            method: "POST",
            body: body
        )
        TokenStorage.accessToken = result.accessToken
        TokenStorage.refreshToken = result.refreshToken
        TokenStorage.userId = result.user.id
        return (result.user, result.isNewUser ?? false)
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

    // MARK: Update Profile
    func updateProfile(name: String, location: String, university: String? = nil, phoneNumber: String? = nil, preferredCategory: String? = nil) async throws -> UserDTO {
        var body: [String: Any] = [
            "name": name,
            "location": location
        ]
        
        if let university { body["university"] = university }
        if let phoneNumber { body["phoneNumber"] = phoneNumber }
        if let preferredCategory { body["preferredCategory"] = preferredCategory }
        
        return try await APIClient.shared.request(
            endpoint: "/auth/profile",
            method: "PATCH",
            body: body,
            authenticated: true
        )
    }

    func uploadProfileImage(image: UIImage) async throws -> UserDTO {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { throw APIError.noData }
        
        guard let url = URL(string: API.baseURL + "/auth/profile/photo") else {
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
        bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        bodyData.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        bodyData.append(imageData)
        bodyData.append("\r\n".data(using: .utf8)!)
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = bodyData
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let wrapper = try decoder.decode(APIResponse<UserDTO>.self, from: data)
        
        guard wrapper.success, let dto = wrapper.data else {
            throw APIError.serverError(wrapper.message ?? "Upload failed")
        }
        
        return dto
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
