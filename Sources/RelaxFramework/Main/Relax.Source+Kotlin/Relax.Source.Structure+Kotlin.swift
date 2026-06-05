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

extension KotlinSource {
    func appendStructure(
        _ structure: Relax.Source.Structure,
        _ sources: Relax.Source.Sources,
        _ framework: Platform.KotlinFramework,
        filename: String,
        includeGeneratedComment: Bool
    ) {
        appendHeading(
            filename: filename,
            package: structure.namespace,
            includeGeneratedComment: includeGeneratedComment
        )

        appendStructure(structure, sources, framework, discriminator: nil, sharedProperties: [], currentNamespace: structure.namespace)

        append()

        resolveImportsPlaceholder()
    }

    func appendStructure(
        _ structure: Relax.Source.Structure,
        _ sources: Relax.Source.Sources,
        _ framework: Platform.KotlinFramework,
        discriminator: Relax.Source.Discriminator?,
        sharedProperties: [Relax.Source.Property],
        currentNamespace: String?
    ) {
        if let schemaName = structure.schemaName, schemaName != structure.name {
            // TODO: append("/// \(schemaName)")
        }

        let something: String
        switch framework {
        case .kotlinx:
            importPackage("kotlinx.serialization.Serializable")
            append("@Serializable")
            if let discriminator {
                let property = structure.properties.firstWith(name: discriminator.discriminatorPropertyName)
                let propertyValue = property?.value ?? "UNKNOWN"

                let enumerationName = escapeKeyword(discriminator.enumeration.mapping.first { $0.value == propertyValue }?.name ?? "UNKNOWN")
                something = " : \(discriminator.name)(\(discriminator.enumeration.name).\(enumerationName))"

                importPackage("kotlinx.serialization.SerialName")
                append("@SerialName(\"\(propertyValue)\")")
            } else {
                something = ""
            }
        case .moshi:
            if let discriminator {
                let property = structure.properties.firstWith(name: discriminator.discriminatorPropertyName)
                let propertyValue = property?.value ?? "UNKNOWN"

                let enumerationName = escapeKeyword(discriminator.enumeration.mapping.first { $0.value == propertyValue }?.name ?? "UNKNOWN")
                something = " : \(discriminator.name)(\(discriminator.enumeration.name).\(enumerationName))"
            } else {
                something = ""
            }

            importPackage("com.squareup.moshi.JsonClass")
            append("@JsonClass(generateAdapter = true)")
        }

        append("data class \(structure.name)(")
        indent {
            let sharedPropertyNames = sharedProperties.map(\.name)
            for property in structure.properties {
                if discriminator?.discriminatorPropertyName == property.name {
                    continue
                }
                let override = sharedPropertyNames.contains(property.name)
                appendProperty(property, framework, override: override, currentNamespace: currentNamespace)
            }

            removeLastBlankLine()
            removeTrailingComma()

            append()
        }

        let enumerations = structure.properties.enumerations

        if enumerations.isEmpty {
            append(")\(something)")
        } else {
            append(")\(something)") {
                for enumeration in enumerations {
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
                    appendEnumeration(enumeration, framework)
                    append()
                }
            }
        }

        for schemaName in structure.properties.uniqueSchemaNames {
            if var innerStructure = sources.structures.firstWith(schemaName: schemaName) {
                if innerStructure.namespace == nil {
                    innerStructure.codable = structure.codable
                    append()
                    appendStructure(innerStructure, sources, framework, discriminator: nil, sharedProperties: [], currentNamespace: currentNamespace)
                }
            }
        }

        append()
    }
}
