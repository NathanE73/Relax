import Foundation

extension Backend {
    struct Order: Codable, Equatable, Identifiable {
        var id: Int
        var orderStatus: OrderStatus
    }
}
