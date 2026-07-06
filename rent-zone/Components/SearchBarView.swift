import SwiftUI

/// A custom, highly reusable search bar component mimicking the native iOS `.searchable` focus and cancel transition.
/// When focused, the search bar shrinks and a custom close/cross button slides in from the right off-screen.
struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var isCapsule: Bool = true
    var backgroundColor: Color = Color(uiColor: .secondarySystemGroupedBackground)
    var horizontalPadding: CGFloat = 16
    
    @FocusState private var isFocused: Bool
    @State private var showButton: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 17))
                    .focused($isFocused)
                    .submitLabel(.search)
                
            }
            .padding(.vertical, isCapsule ? 14 : 10)
            .padding(.horizontal, 16)
            .background(
                Group {
                    if isCapsule {
                        Capsule()
                            .fill(backgroundColor)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(backgroundColor)
                    }
                }
            )
            
            if showButton {
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        text = ""
                        isFocused = false
                        showButton = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.primary.opacity(0.65))
                        .padding(11)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.65),
                                            .white.opacity(0.15),
                                            .clear,
                                            .white.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .overlay(
                            // Specular gloss reflection (liquid shine)
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.25), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .padding(1)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                .transition(.asymmetric(
                    insertion: .offset(x: 50).combined(with: .opacity),
                    removal: .offset(x: 50).combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal, horizontalPadding)
        .onChange(of: isFocused) { _, newValue in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                showButton = newValue
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SearchBarView(text: .constant(""), placeholder: "Search inside Capsule")
        SearchBarView(text: .constant("Test"), placeholder: "Search inside Capsule with Text")
        SearchBarView(text: .constant(""), placeholder: "Search inside Rounded Rectangle", isCapsule: false, backgroundColor: Color(.systemGray6))
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
