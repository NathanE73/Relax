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
        includeGeneratedComment: Bool
    ) {
        appendHeading(
            filename: filename,
            imports: ["Foundation"],
            includeGeneratedComment: includeGeneratedComment
        )

        if let namespace = structure.namespace {
            append("extension \(namespace)") {
                appendStructure(structure, sources, currentNamespace: namespace)
            }
        } else {
            appendStructure(structure, sources, currentNamespace: nil)
        }

        append()
    }

    func appendStructure(
        _ structure: Relax.Source.Structure,
        _ sources: Relax.Source.Sources,
        currentNamespace: String?
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
                appendProperty(property, currentNamespace: currentNamespace)
            }

            append()

            // TODO: interleave discriminators, enumerations, and structures?

            for property in structure.properties {
                if case let .enumeration(enumeration) = property.type {
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
                }
            }

            for schemaName in structure.properties.uniqueSchemaNames {
                if var innerStructure = sources.structures.firstWith(schemaName: schemaName) {
                    if innerStructure.namespace == nil {
                        innerStructure.codable = structure.codable
                        append()
                        appendStructure(innerStructure, sources, currentNamespace: currentNamespace)
                    }
                }
            }
        }
    }
}
