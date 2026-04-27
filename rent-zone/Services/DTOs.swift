import Foundation

// MARK: - User DTO
struct UserDTO: Decodable, Identifiable {
    let id: String
    let name: String
    let location: String
    let university: String?
    let phoneNumber: String?
    let preferredCategory: String?
    let isVerified: Bool
    let profileImage: String?
    let favouriteProductIds: [String]
    let createdAt: String?

    // From account include
    let provider: String?
    let email: String?

    // Convert to app model
    func toUser() -> User {
        User(
            id: id,
            name: name,
            location: location,
            isVerified: isVerified,
            profileImage: profileImage,
            email: email
        )
    }
}

// MARK: - Category DTO
struct CategoryDTO: Decodable, Identifiable {
    let id: String
    let name: String
    let image: String
    let type: String
    // _count from Prisma include
    let count: CountDTO?

    enum CodingKeys: String, CodingKey {
        case id, name, image, type
        case count = "_count"
    }

    func toCategory() -> Category {
        Category(
            id: id,
            name: name,
            images: image,
            type: type == "men" ? .men : .women
        )
    }
}

struct CountDTO: Decodable {
    let products: Int?
    let reviews: Int?
}

// MARK: - Product DTO
struct ProductDTO: Decodable, Identifiable {
    let id: String
    let name: String
    let rentPricePerDay: Double
    let securityDeposit: Double
    let condition: String
    let size: String
    let description: [String: String]?
    let bookedDates: [String]?
    let listedByUserId: String
    let categoryId: String
    let pickupLocation: String
    let imageURLs: [String]
    let rating: Double
    let occasion: String?
    let createdAt: String?

    // Includes
    let listedBy: ListedByDTO?
    let category: CategoryDTO?
    let reviews: [ReviewDTO]?
    let count: CountDTO?

    enum CodingKeys: String, CodingKey {
        case id, name, rentPricePerDay, securityDeposit, condition, size
        case description, bookedDates, listedByUserId, categoryId, pickupLocation
        case imageURLs, rating, occasion, createdAt, listedBy, category, reviews
        case count = "_count"
    }

    func toProduct() -> Product {
        let conditionEnum: ProductCondition = {
            switch condition {
            case "new": return .new
            case "likeNew": return .likeNew
            case "good": return .good
            case "worn": return .worn
            default: return .good
            }
        }()

        var descriptionMap: [DescriptionTypes: String] = [:]
        if let desc = description {
            for (key, value) in desc {
                if let dtype = DescriptionTypes(rawValue: key) {
                    descriptionMap[dtype] = value
                }
            }
        }

        let parsedBookedDates: [Date] = (bookedDates ?? []).compactMap { dateStr in
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: dateStr)
        }

        return Product(
            id: id,
            name: name,
            rentPricePerDay: rentPricePerDay,
            securityDeposit: securityDeposit,
            condition: conditionEnum,
            size: size,
            description: descriptionMap,
            bookedDates: parsedBookedDates,
            listedByUserId: listedByUserId,
            listedBy: listedBy,
            categoryId: categoryId,
            pickupLocation: pickupLocation,
            imageURLs: imageURLs,
            reviews: (reviews ?? []).map { $0.toReview() },
            rating: rating,
            occasion: occasion
        )
    }
}

struct ListedByDTO: Decodable, Equatable, Hashable {
    let id: String
    let name: String
    let profileImage: String?
    let isVerified: Bool?
    let location: String?
}

// MARK: - Review DTO
struct ReviewDTO: Decodable, Identifiable {
    let id: String
    let productId: String
    let userId: String
    let rating: Int
    let content: String
    let imageURLs: [String]
    let createdAt: String?
    let user: ReviewUserDTO?

    func toReview() -> Review {
        Review(
            id: id,
            productId: productId,
            userId: userId,
            rating: rating,
            content: content,
            imageURLs: imageURLs,
            userName: user?.name,
            userImage: user?.profileImage
        )
    }
}

struct ReviewUserDTO: Decodable {
    let id: String
    let name: String
    let profileImage: String?
}

// MARK: - Rental DTO
struct RentalDTO: Decodable, Identifiable {
    let id: String
    let productId: String
    let rentedByUserId: String
    let rentedFromUserId: String
    let startDate: String
    let endDate: String
    let totalPrice: Double
    let status: String
    let createdAt: String?

    func toRental() -> Rental {
        let fmt = ISO8601DateFormatter()
        let statusEnum: RentalStatus = {
            switch status {
            case "requested": return .requested
            case "approved": return .approved
            case "active": return .active
            case "returned": return .returned
            case "cancelled": return .cancelled
            default: return .requested
            }
        }()
        return Rental(
            id: id,
            productId: productId,
            rentedByUserId: rentedByUserId,
            rentedFromUserId: rentedFromUserId,
            startDate: fmt.date(from: startDate) ?? Date(),
            endDate: fmt.date(from: endDate) ?? Date(),
            totalPrice: totalPrice,
            status: statusEnum
        )
    }
}

// MARK: - Notification DTO
struct NotificationDTO: Decodable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let content: String
    let icon: String
    let isRead: Bool
    let type: String
    let status: String
    let productId: String?
    let fromUserId: String?
    let rentalDate: String?
    let totalPrice: Double?
    let productImageName: String?
    let productName: String?
    let requesterName: String?
    let createdAt: String?

    func toNotification() -> AppNotification {
        let typeEnum: NotificationType = type == "rentalRequest" ? .rentalRequest : .general
        let statusEnum: NotificationStatus = {
            switch status {
            case "accepted": return .accepted
            case "rejected": return .rejected
            default: return .pending
            }
        }()
        let fmt = ISO8601DateFormatter()
        return AppNotification(
            id: id,
            userId: userId,
            title: title,
            content: content,
            icon: icon,
            createdAt: createdAt.flatMap { fmt.date(from: $0) } ?? Date(),
            isRead: isRead,
            type: typeEnum,
            status: statusEnum,
            productId: productId,
            fromUserId: fromUserId,
            rentalDate: rentalDate.flatMap { fmt.date(from: $0) },
            totalPrice: totalPrice,
            productImageName: productImageName,
            productName: productName,
            requesterName: requesterName
        )
    }
}

// MARK: - Paginated Products Response
struct PaginatedProducts: Decodable {
    let products: [ProductDTO]
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int
}
