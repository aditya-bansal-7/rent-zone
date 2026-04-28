import Foundation
import GoogleSignIn
import SwiftUI

class GoogleSignInHelper {
    static let shared = GoogleSignInHelper()
    private init() {}
    
    @MainActor
    func signIn() async throws -> GIDSignInResult {
        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
            throw NSError(domain: "GoogleSignInHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
        }
        
        return try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
    }
}
