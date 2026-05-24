import Foundation

extension Backend {
    struct Dog: Codable, Equatable {
        let petType = Pet.PetType.dog
        var name: String
        var bark: Bool
        var breed: String
    }
}
