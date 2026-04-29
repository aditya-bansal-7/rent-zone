import SwiftUI

struct SectionHeaderView<Destination: View>: View {
    let title: String
    let destination: Destination?
    let showViewAll: Bool
    
    init(title: String, destination: Destination? = nil, showViewAll: Bool = true) {
        self.title = title
        self.destination = destination
        self.showViewAll = showViewAll
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .tracking(0.5)
            
            Spacer()
            
            if showViewAll {
                if let destination = destination {
                    NavigationLink(destination: destination) {
                        Text("View All")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                } else {
                    // If no destination but showViewAll is true, we might want a button or just nothing
                    // The user's original code had an empty button.
                }
            }
        }
        .padding(.top, 8)
    }
}

// Extension to allow non-generic initialization when no destination is needed
extension SectionHeaderView where Destination == EmptyView {
    init(title: String, showViewAll: Bool = false) {
        self.init(title: title, destination: nil, showViewAll: showViewAll)
    }
}

#Preview {
    VStack {
        SectionHeaderView(title: "POPULAR OUTFITS", destination: Text("Detail"))
        SectionHeaderView(title: "SEARCH RESULTS", showViewAll: false)
    }
    .padding()
}
