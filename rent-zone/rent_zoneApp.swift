import SwiftUI

@main
struct rent_zoneApp: App {
    @State private var appStore = AppStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environment(appStore)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .environment(appStore)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
    }
}
