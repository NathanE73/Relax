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
    func appendStructure(
        _ structure: Relax.Source.Structure,
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

        if let namespace = structure.namespace {
            append("extension \(namespace)") {
                appendStructure(structure, sources, currentNamespace: namespace, discriminatorPropertyName: nil, naming: naming)
            }
        } else {
            appendStructure(structure, sources, currentNamespace: nil, discriminatorPropertyName: nil, naming: naming)
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

        resolveImportsPlaceholder()
    }

    func appendStructure(
        _ structure: Relax.Source.Structure,
        _ sources: Relax.Source.Sources,
        currentNamespace: String?,
        discriminatorPropertyName: String?,
        naming: SourceNaming
    ) {
        let isIdentifiable = structure.identifiablePropertyName != nil || structure.properties.firstWith(name: "id") != nil

        let protocols = ([
            structure.codable.swiftName,
            "Equatable",
            isIdentifiable ? "Identifiable" : nil,
        ] as [String?])
            .compactMap(\.self)
            .joined(separator: ", ")

        if let schemaName = structure.schemaName, schemaName != structure.name {
            // TODO: append("/// \(schemaName)")
        }
        append("struct \(structure.name): \(protocols)") {
            if let propertyName = structure.identifiablePropertyName {
                if let identifiableProperty = structure.properties.firstWith(name: propertyName) {
                    appendIdentifiableProperty(identifiableProperty)
                    append()
                }
            }

            for property in structure.properties {
                if !structure.codable.isEncodable, property.name == discriminatorPropertyName {
                    continue
                }
                appendProperty(property, currentNamespace: currentNamespace)
            }

            append()

            // TODO: interleave discriminators, enumerations, and structures?

            for property in structure.properties {
                switch property.type {
                case let .discriminator(discriminator):
                    let discriminator = Relax.Source.Discriminator(
                        existing: false,
                        schemaName: nil,
                        namespace: nil,
                        name: discriminator.name,
                        codable: structure.codable,
                        discriminatorPropertyName: discriminator.discriminatorPropertyName,
                        mapping: discriminator.mapping.map {
                            Relax.Source.Discriminator.Mapping(
                                value: $0.value,
                                schemaName: $0.schemaName,
                                name: naming.typeName($0.value)
                            )
                        },
                        enumeration: Relax.Source.Enumeration(
                            existing: false,
                            schemaName: nil,
                            namespace: nil,
                            name: naming.typeName(discriminator.discriminatorPropertyName),
                            codable: structure.codable,
                            mapping: discriminator.mapping.map {
                                Relax.Source.Enumeration.Mapping(
                                    value: $0.value,
                                    name: naming.caseName($0.value)
                                )
                            }
                        )
                    )
                    discriminators.append(discriminator)
                    append()
                    appendDiscriminator(discriminator, sources, naming: naming)
                case let .enumeration(enumeration):
                    let enumeration = Relax.Source.Enumeration(
                        existing: false,
                        schemaName: nil,
                        namespace: nil,
                        name: enumeration.name,
                        codable: structure.codable,
                        mapping: enumeration.mapping.map {
                            Relax.Source.Enumeration.Mapping(
                                value: $0.value,
                                name: $0.name
                            )
                        }
                    )
                    append()
                    appendEnumeration(enumeration)
                default:
                    break
                }
            }

            for schemaName in structure.properties.uniqueSchemaNames {
                if var innerStructure = sources.structures.firstWith(schemaName: schemaName) {
                    if innerStructure.namespace == nil {
                        innerStructure.codable = structure.codable
                        append()
                        appendStructure(innerStructure, sources, currentNamespace: currentNamespace, discriminatorPropertyName: nil, naming: naming)
                    }
                }
            }
        }
    }
}
