//
// Copyright (c) 2026 Nathan E. Walczak
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

extension SwiftSource {
    func appendDiscriminators(
        _ discriminators: [Relax.Discriminator],
        currentNamespace: String?
    ) {
        for discriminator in discriminators {
            appendDiscriminator(discriminator, currentNamespace: currentNamespace)
            append()
        }
    }

    func appendDiscriminator(
        _ discriminator: Relax.Discriminator,
        currentNamespace: String?
    ) {
        let protocols = "\(discriminator.codable.swiftName), Equatable"

        append("@CasePathable")
        append("@dynamicMemberLookup")
        append("enum \(discriminator.name): \(protocols)") {
            for mapping in discriminator.mapping {
                let mappingName = SwiftNaming.escapeKeyword(SwiftNaming.methodName(from: mapping.name))
                append("case \(mappingName)(\(mapping.type))")
            }

            append()

            appendEnumerations(discriminator.enumerations)
            appendStructures(discriminator.structures, discriminator: discriminator, currentNamespace: currentNamespace)

            appendSharedDiscriminatorProperties(discriminator)
        }
    }

    func appendSharedDiscriminatorProperties(_ discriminator: Relax.Discriminator) {
        guard let firstStructure = discriminator.structures.first else { return }

        let sharedPropertyNames = discriminator.structures.sharedPropertyNames

        let properties = firstStructure.properties
            .filter { sharedPropertyNames.contains($0.name) }
            .filter { $0.name != discriminator.discriminatorProperty.name }

        for property in properties {
            let propertyType = property.type
            append("var \(property.name): \(propertyType.swiftName)") {
                append("switch self {")
                for mapping in discriminator.mapping {
                    let mappingName = SwiftNaming.escapeKeyword(SwiftNaming.methodName(from: mapping.name))
                    append("case let .\(mappingName)(\(mappingName)): \(mappingName).\(property.name)")
                }
                append("}")
            }
            append()
        }
    }

    func appendDecodableDiscriminator(_ discriminator: Relax.Discriminator) {
        let discriminatorProperty = discriminator.discriminatorProperty

        append("extension KeyedDecodingContainer") {
            append("private struct Having\(discriminatorProperty.type): Decodable") {
                append("var \(discriminatorProperty.name): \(discriminator.fullyQualifiedName).\(discriminatorProperty.type)")
            }
            append()

            append("func decode(_: \(discriminator.fullyQualifiedName).Type, forKey key: Key) throws -> \(discriminator.fullyQualifiedName)") {
                append("switch try decode(Having\(discriminatorProperty.type).self, forKey: key).\(discriminatorProperty.name) {")
                for mapping in discriminator.mapping {
                    let mappingName = SwiftNaming.escapeKeyword(SwiftNaming.methodName(from: mapping.name))
                    append("case .\(mappingName):")
                    indent {
                        append("try .\(mappingName)(decode(\(discriminator.fullyQualifiedName).\(mapping.type).self, forKey: key))")
                    }
                }
                append("}")
            }
            append()

            append("func decode(_: [\(discriminator.fullyQualifiedName)].Type, forKey key: Key) throws -> [\(discriminator.fullyQualifiedName)]") {
                append("var elements: [\(discriminator.fullyQualifiedName)] = []")
                append()
                append("var resultContainer = try nestedUnkeyedContainer(forKey: key)")
                append("var elementContainer = try nestedUnkeyedContainer(forKey: key)")
                append()
                append("while !resultContainer.isAtEnd") {
                    append("switch try resultContainer.decode(Having\(discriminatorProperty.type).self).\(discriminatorProperty.name) {")
                    for mapping in discriminator.mapping {
                        let mappingName = SwiftNaming.escapeKeyword(SwiftNaming.methodName(from: mapping.name))
                        append("case .\(mappingName):")
                        indent {
                            append("try elements.append(.\(mappingName)(elementContainer.decode(\(discriminator.fullyQualifiedName).\(mapping.type).self)))")
                        }
                    }
                    append("}")
                }
                append()
                append("return elements")
            }
        }
    }

    func appendEncodableDiscriminator(_ discriminator: Relax.Discriminator) {
        append("extension \(discriminator.fullyQualifiedName)") {
            append("func encode(to encoder: any Encoder) throws") {
                append("var container = encoder.singleValueContainer()")
                append("switch self {")

                for mapping in discriminator.mapping {
                    let mappingName = SwiftNaming.escapeKeyword(SwiftNaming.methodName(from: mapping.name))
                    append("case let .\(mappingName)(\(mappingName)):")
                    indent {
                        append("try container.encode(\(mappingName))")
                    }
                }

                append("}")
            }
        }
    }
}
