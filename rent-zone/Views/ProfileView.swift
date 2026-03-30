import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isListingSheetPresented = false
    
    var body: some View {
        ZStack {
            // Gradient background for glass effect visibility
            LinearGradient(
                colors: [
                    Color(.systemGray6),
                    Color.white,
                    Color(.systemGray6).opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Profile Header
                    VStack(spacing: 12) {
                        // Profile Image
                        Image("profile_photo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
                        
                        // Name
                        Text("Payal Singh")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        
                        // Email
                        Text("payalsingh1031@gmail.com")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        // Edit Profile Button
                        Button(action: {}) {
                            Text("Edit Profile")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .stroke(Color(.systemGray3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                    
                    // MARK: - Menu Items
                    menuItems
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .sheet(isPresented: $isListingSheetPresented) {
            ListingInfoView()
        }
    }
    
    @ViewBuilder
    private var menuItems: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                VStack(spacing: 12) {
                    ProfileMenuRow(icon: "doc.text", title: "My Listing", action: { isListingSheetPresented = true })
                    ProfileMenuRow(icon: "heart", title: "Favourite")
                    ProfileMenuRow(icon: "gearshape", title: "Settings")
                    ProfileMenuRow(icon: "questionmark.circle", title: "Help & Support")
                    ProfileMenuRow(icon: "textformat.size", title: "Language")
                    
                    // Sign Out Button
                    Button(action: {}) {
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
            }
        } else {
            VStack(spacing: 12) {
                ProfileMenuRowLegacy(icon: "doc.text", title: "My Listing", action: { isListingSheetPresented = true })
                ProfileMenuRowLegacy(icon: "heart", title: "Favourite")
                ProfileMenuRowLegacy(icon: "gearshape", title: "Settings")
                ProfileMenuRowLegacy(icon: "questionmark.circle", title: "Help & Support")
                ProfileMenuRowLegacy(icon: "textformat.size", title: "Language")
                
                Button(action: {}) {
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Profile Menu Row (iOS 26+ with Liquid Glass)
struct ProfileMenuRow: View {
    let icon: String
    let title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.primary.opacity(0.7))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .modifier(GlassModifier())
    }
}

// MARK: - Glass Modifier with availability check
struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
        }
    }
}

// MARK: - Profile Menu Row (Legacy fallback)
struct ProfileMenuRowLegacy: View {
    let icon: String
    let title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.primary.opacity(0.7))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

#Preview {
    ProfileView()
}
