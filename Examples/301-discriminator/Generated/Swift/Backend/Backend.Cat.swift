import Foundation

extension Backend {
    struct Cat: Codable, Equatable {
        let petType = Pet.PetType.cat
        var name: String
        var meow: Bool
        var lives: Int
    }
}
