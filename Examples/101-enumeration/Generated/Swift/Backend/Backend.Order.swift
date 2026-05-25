import Foundation

extension Backend {
    struct Order: Codable, Equatable, Identifiable {
        var id: Int
        var orderStatus: OrderStatus

        enum OrderStatus: String, Codable {
            case placed
            case processing
            case shipped
            case delivered
        }
    }
}
