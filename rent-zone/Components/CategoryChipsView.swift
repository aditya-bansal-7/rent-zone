import SwiftUI

struct CategoryChipsView: View {
    @Environment(AppStore.self) var appStore
    @Binding var selectedCategory: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(appStore.categoryStore.categories) { category in
                    categoryChip(category: category)
                }
            }
        }
    }
    
    private func categoryChip(category: Category) -> some View {
        let isSelected = selectedCategory == category.name
        return Button(action: {
            selectedCategory = category.name
        }) {
            HStack(spacing: 6) {
                if category.images.hasPrefix("http"), let url = URL(string: category.images) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 16, height: 16)
                                .clipShape(Circle())
                        } else if case .empty = phase {
                            ProgressView()
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 13))
                        }
                    }
                } else if UIImage(named: category.images) != nil {
                    Image(category.images)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                } else {
                    // Fallback to system name if no local image or URL
                    Image(systemName: category.images)
                        .font(.system(size: 13))
                }
                Text(category.name)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primary : Color(UIColor.systemBackground))
            .foregroundColor(isSelected ? Color(UIColor.systemBackground) : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

#Preview {
    CategoryChipsView(selectedCategory: .constant("All Items"))
        .environment(AppStore())
}
