import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    @State private var isListingSheetPresented = false
    @State private var isEditProfilePresented = false
    @State private var isFavoritesPresented = false
    @State private var isSettingsPresented = false
    @State private var isHelpPresented = false
    @State private var isLanguagePresented = false
    @State private var isSigningOut = false

    private var user: User? { appStore.userStore.currentUser }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemGray6), Color.white, Color(.systemGray6).opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Close button
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background {
                                    Group {
                                        if #available(iOS 26.0, *) {
                                            Color.clear
                                        } else {
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                        }
                                    }
                                }
                                .if26GlassEffect(cornerRadius: 22)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    // MARK: - Profile Header
                    VStack(spacing: 12) {
                        // Profile Image
                        Group {
                            if let imageURL = user?.profileImage, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    case .failure(_), .empty:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundStyle(.gray)
                                    @unknown default:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundStyle(.gray)
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)

                       

                        // Name
                        Text(user?.name ?? "Guest")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)

                        // Email / Location
                        if let email = user?.email {
                            Text(email)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }

                        if let location = user?.location, !location.isEmpty {
                            Label(location, systemImage: "mappin.and.ellipse")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }

                        // Edit Profile Button
                        Button(action: { isEditProfilePresented = true }) {
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
        .sheet(isPresented: $isEditProfilePresented) {
            EditProfileView()
        }
        .sheet(isPresented: $isFavoritesPresented) {
            FavoritesView()
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
        .sheet(isPresented: $isHelpPresented) {
            HelpAndSupportView()
        }
        .sheet(isPresented: $isLanguagePresented) {
            LanguageSettingsView()
        }
    }

    @ViewBuilder
    private var menuItems: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                VStack(spacing: 12) {
                    ProfileMenuRow(icon: "doc.text", title: "My Listing", action: { isListingSheetPresented = true })
                    ProfileMenuRow(icon: "heart", title: "Favourites", action: { isFavoritesPresented = true })
                    ProfileMenuRow(icon: "gearshape", title: "Settings", action: { isSettingsPresented = true })
                    ProfileMenuRow(icon: "questionmark.circle", title: "Help & Support", action: { isHelpPresented = true })
                    ProfileMenuRow(icon: "textformat.size", title: "Language", action: { isLanguagePresented = true })

                    Button(action: handleSignOut) {
                        HStack {
                            Spacer()
                            if isSigningOut {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                            }
                            Spacer()
                        }
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
                ProfileMenuRowLegacy(icon: "heart", title: "Favourites", action: { isFavoritesPresented = true })
                ProfileMenuRowLegacy(icon: "gearshape", title: "Settings", action: { isSettingsPresented = true })
                ProfileMenuRowLegacy(icon: "questionmark.circle", title: "Help & Support", action: { isHelpPresented = true })
                ProfileMenuRowLegacy(icon: "textformat.size", title: "Language", action: { isLanguagePresented = true })

                Button(action: handleSignOut) {
                    HStack {
                        Spacer()
                        if isSigningOut {
                            ProgressView()
                        } else {
                            Text("Sign Out")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
        }
    }

    private func handleSignOut() {
        isSigningOut = true
        Task {
            await appStore.userStore.logout()
            await MainActor.run {
                self.isSigningOut = false
                dismiss()
            }
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

// MARK: - Glass Modifier
struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            content
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
        }
    }
}

// MARK: - Profile Menu Row (Legacy)
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
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppStore())
}
