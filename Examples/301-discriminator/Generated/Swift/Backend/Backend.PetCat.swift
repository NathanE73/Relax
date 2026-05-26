import Foundation

extension Backend {
    struct PetCat: Codable, Equatable {
        let petType = Pet.PetType.cat
        var name: String
        var meow: Bool
        var lives: Int
    }
}
