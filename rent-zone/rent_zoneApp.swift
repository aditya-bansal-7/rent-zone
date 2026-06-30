import SwiftUI

@main
struct rent_zoneApp: App {
    @State private var appStore = AppStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        // Reset the system language back to default English
        // (Clears the override left behind by the deleted LanguageManager)
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        UserDefaults.standard.removeObject(forKey: "appLanguage")
    }
    
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
