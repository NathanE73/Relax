import Foundation

extension Backend {
    enum OrderStatus: String, Codable {
        case placed
        case processing
        case shipped
        case delivered
    }
}
