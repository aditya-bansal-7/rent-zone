import SwiftUI

struct CategoryChipsView: View {
    @EnvironmentObject var appStore: AppStore
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
                Image(systemName: category.images)
                    .font(.system(size: 13))
                Text(category.name)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.black : Color.white)
            .foregroundColor(isSelected ? .white : .black)
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
        .environmentObject(AppStore())
}
