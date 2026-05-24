import CasePaths
import Foundation

extension Backend {
    @CasePathable
    @dynamicMemberLookup
    enum Pet: Codable, Equatable {
        case cat(Cat)
        case dog(Dog)

        enum PetType: String, Codable {
            case cat = "Cat"
            case dog = "Dog"
        }

        struct Cat: Codable, Equatable {
            let petType = PetType.Cat
            var name: String
            var meow: Bool
            var lives: Int
        }

        struct Dog: Codable, Equatable {
            let petType = PetType.Dog
            var name: String
            var bark: Bool
            var breed: String
        }

        var name: String {
            switch self {
            case let .cat(cat): cat.name
            case let .dog(dog): dog.name
            }
        }
    }
}

extension KeyedDecodingContainer {
    private struct HavingPetType: Decodable {
        var petType: Backend.Pet.PetType
    }

    func decode(_: Backend.Pet.Type, forKey key: Key) throws -> Backend.Pet {
        switch try decode(HavingPetType.self, forKey: key).petType {
        case .cat:
            try .cat(decode(Backend.Pet.Cat.self, forKey: key))
        case .dog:
            try .dog(decode(Backend.Pet.Dog.self, forKey: key))
        }
    }

    func decode(_: [Backend.Pet].Type, forKey key: Key) throws -> [Backend.Pet] {
        var elements: [Backend.Pet] = []

        var resultContainer = try nestedUnkeyedContainer(forKey: key)
        var elementContainer = try nestedUnkeyedContainer(forKey: key)

        while !resultContainer.isAtEnd {
            switch try resultContainer.decode(HavingPetType.self).petType {
            case .cat:
                try elements.append(.cat(elementContainer.decode(Backend.Pet.Cat.self)))
            case .dog:
                try elements.append(.dog(elementContainer.decode(Backend.Pet.Dog.self)))
            }
        }

        return elements
    }
}

extension Backend.Pet {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .cat(cat):
            try container.encode(cat)
        case let .dog(dog):
            try container.encode(dog)
        }
    }
}
