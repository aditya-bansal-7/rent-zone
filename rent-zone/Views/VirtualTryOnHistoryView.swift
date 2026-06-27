import SwiftUI

struct VirtualTryOnHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStore.self) private var appStore
    @State private var tryOns: [TryOnDTO] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            fetchTryOns()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.brandPurple)
                    }
                    .padding()
                } else if tryOns.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No Virtual Try-Ons yet")
                            .font(.headline)
                        Text("Go to a product page and tap 'Virtual Try-On' to see how it looks on you!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(tryOns) { tryOn in
                                if let product = tryOn.product {
                                    NavigationLink {
                                        TryOnResultWrapper(productId: tryOn.productId, resultImageURL: tryOn.resultImageURL)
                                    } label: {
                                        TryOnHistoryCard(tryOn: tryOn, product: product)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Virtual Try-Ons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DismissButton(action: { dismiss() })
                }
            }
        }
        .task {
            if tryOns.isEmpty {
                fetchTryOns()
            }
        }
    }

    private func fetchTryOns() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let results = try await TryOnService.shared.getMyTryOns()
                await MainActor.run {
                    self.tryOns = results
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct TryOnHistoryCard: View {
    let tryOn: TryOnDTO
    let product: TryOnProductDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: tryOn.resultImageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure(_), .empty:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(product.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .padding(.horizontal, 4)
            
            if let date = formattedDate {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 8)
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var formattedDate: Date? {
        guard let dateString = tryOn.createdAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString)
    }
}

struct TryOnResultWrapper: View {
    let productId: String
    let resultImageURL: String
    @State private var product: Product?
    @State private var isLoading = true
    @Environment(AppStore.self) private var appStore
    
    var body: some View {
        Group {
            if let product {
                TryOnResultView(product: product, resultImageURL: resultImageURL)
            } else if isLoading {
                ProgressView()
            } else {
                Text("Product not found")
            }
        }
        .task {
            do {
                product = try await ProductService.shared.getProduct(id: productId)
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}
