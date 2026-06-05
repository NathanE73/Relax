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
    func appendDiscriminator(
        _ discriminator: Relax.Source.Discriminator,
        _ sources: Relax.Source.Sources,
        filename: String,
        includeGeneratedComment: Bool,
        naming: SourceNaming
    ) {
        appendHeading(
            filename: filename,
            includeGeneratedComment: includeGeneratedComment
        )

        importPackage("Foundation")

        discriminators.append(discriminator)

        if let namespace = discriminator.namespace {
            append("extension \(namespace)") {
                appendDiscriminator(discriminator, sources, naming: naming)
            }
        } else {
            appendDiscriminator(discriminator, sources, naming: naming)
        }

        append()

        for discriminator in discriminators {
            if discriminator.codable.isDecodable {
                appendDecodableDiscriminator(discriminator)
            }

            if discriminator.codable.isEncodable {
                appendEncodableDiscriminator(discriminator)
            }

            append()
        }

        append()

        resolveImportsPlaceholder()
    }

    func appendDiscriminator(
        _ discriminator: Relax.Source.Discriminator,
        _ sources: Relax.Source.Sources,
        naming: SourceNaming
    ) {
        let protocols = "\(discriminator.codable.swiftName), Equatable"

        importPackage("CasePaths")
        append("@CasePathable")
        append("@dynamicMemberLookup")
        append("enum \(discriminator.name): \(protocols)") {
            for (mapping, enumeration) in zip(discriminator.mapping, discriminator.enumeration.mapping) {
                let caseName = escapeKeyword(enumeration.name)
                append("case \(caseName)(\(mapping.name))")
            }

            append()

            appendEnumeration(discriminator.enumeration)

            // TODO: relocate...
            var innerStructures: [Relax.Source.Structure] = []
            for mapping in discriminator.mapping {
                if var innerStructure = sources.structures.firstWith(schemaName: mapping.schemaName) {
                    if innerStructure.namespace == nil {
                        innerStructure.name = mapping.name
                        innerStructure.codable = discriminator.codable
                        // TODO: update discriminator property type and value
                        innerStructure.properties = innerStructure.properties.map { property in
                            if property.name == discriminator.discriminatorPropertyName {
                                var property = property
                                property.type = .schema(PropertyType.Schema(
                                    name: discriminator.enumeration.name,
                                    schemaName: nil,
                                    namespace: nil
                                ))
                                property.value = discriminator.enumeration.name(forValue: property.value) ?? "UNKNOWN"
                                return property
                            } else {
                                return property
                            }
                        }
                        innerStructures.append(innerStructure)
                    }
                }
            }

            for innerStructure in innerStructures {
                append()
                appendStructure(innerStructure, sources, currentNamespace: discriminator.namespace, discriminatorPropertyName: discriminator.discriminatorPropertyName, naming: naming)
            }

            let sharedProperties = innerStructures.sharedProperties()
            if !sharedProperties.isEmpty {
                append()
                appendSharedDiscriminatorProperties(discriminator, sharedProperties)
            }
        }
    }

    func appendSharedDiscriminatorProperties(
        _ discriminator: Relax.Source.Discriminator,
        _ sharedProperties: [Relax.Source.Property]
    ) {
        let properties = sharedProperties
            .filter { $0.name != discriminator.discriminatorPropertyName }

        for property in properties {
            let propertyType = property.type
            let isOptional = property.isOptional ? "?" : ""
            append("var \(property.name): \(propertyType.swiftName)\(isOptional)") {
                append("switch self {")
                for (_, enumeration) in zip(discriminator.mapping, discriminator.enumeration.mapping) {
                    let enumerationName = escapeKeyword(enumeration.name)
                    append("case let .\(enumerationName)(\(enumerationName)): \(enumerationName).\(property.name)")
                }
                append("}")
            }
            append()
        }
    }

    func appendDecodableDiscriminator(_ discriminator: Relax.Source.Discriminator) {
        let discriminatorPropertyName = discriminator.discriminatorPropertyName
        let discriminatorPropertyType = discriminator.enumeration.name

        append("extension KeyedDecodingContainer") {
            append("private struct Having\(discriminatorPropertyType): Decodable") {
                append("var \(discriminatorPropertyName): \(discriminator.fullyQualifiedName).\(discriminatorPropertyType)")
            }
            append()

            append("func decode(_: \(discriminator.fullyQualifiedName).Type, forKey key: Key) throws -> \(discriminator.fullyQualifiedName)") {
                append("switch try decode(Having\(discriminatorPropertyType).self, forKey: key).\(discriminatorPropertyName) {")
                for (mapping, enumeration) in zip(discriminator.mapping, discriminator.enumeration.mapping) {
                    let caseName = escapeKeyword(enumeration.name)
                    append("case .\(caseName):")
                    indent {
                        append("try .\(caseName)(decode(\(discriminator.fullyQualifiedName).\(mapping.name).self, forKey: key))")
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
                    append("switch try resultContainer.decode(Having\(discriminatorPropertyType).self).\(discriminatorPropertyName) {")
                    for (mapping, enumeration) in zip(discriminator.mapping, discriminator.enumeration.mapping) {
                        let caseName = escapeKeyword(enumeration.name)
                        append("case .\(caseName):")
                        indent {
                            append("try elements.append(.\(caseName)(elementContainer.decode(\(discriminator.fullyQualifiedName).\(mapping.name).self)))")
                        }
                    }
                    append("}")
                }
                append()
                append("return elements")
            }
        }
    }

    func appendEncodableDiscriminator(_ discriminator: Relax.Source.Discriminator) {
        append("extension \(discriminator.fullyQualifiedName)") {
            append("func encode(to encoder: any Encoder) throws") {
                append("var container = encoder.singleValueContainer()")
                append("switch self {")

                for mapping in discriminator.enumeration.mapping {
                    let mappingName = escapeKeyword(mapping.name)
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
