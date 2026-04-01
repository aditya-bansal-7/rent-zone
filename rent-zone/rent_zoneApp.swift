import SwiftUI

@main
struct rent_zoneApp: App {
    @State private var appStore = AppStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environment(appStore)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .environment(appStore)
            }
        }
    }
}
