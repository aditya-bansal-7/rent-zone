import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var locationServicesEnabled = true
    
    // For alert presentation
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account").font(.subheadline).foregroundColor(.gray)) {
                    NavigationLink(destination: ChangePasswordView()) {
                        Label("Change Password", systemImage: "lock")
                    }
                }
                
                Section(header: Text("App Settings").font(.subheadline).foregroundColor(.gray)) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell")
                    }
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: "moon")
                    }
                    Toggle(isOn: $locationServicesEnabled) {
                        Label("Location Services", systemImage: "location")
                    }
                    NavigationLink(destination: LanguageSettingsView()) {
                        Label("Language", systemImage: "globe")
                    }
                }
                
                Section(header: Text("Support & Legal").font(.subheadline).foregroundColor(.gray)) {
                    NavigationLink(destination: HelpAndSupportView()) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    NavigationLink(destination: Text("Terms of Service Content").navigationTitle("Terms of Service")) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
                
                Section(header: Text("Data").font(.subheadline).foregroundColor(.gray)) {
                    Button(action: {
                        // Clear cache action
                    }) {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundColor(.primary)
                    }
                }
                
                Section {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Label("Delete Account", systemImage: "person.crop.circle.badge.xmark")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Perform account deletion logic here
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
