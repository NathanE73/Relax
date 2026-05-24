import Foundation

extension Backend {
    struct User: Codable, Equatable, Identifiable {
        var id: Int
        var username: String
        var bio: String?
    }
}
