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
    func appendDiscriminator(
        _ discriminator: Relax.Source.Discriminator,
        _ sources: Relax.Source.Sources,
        _ framework: Platform.KotlinFramework,
        filename: String,
        includeGeneratedComment: Bool
    ) {
        appendHeading(
            filename: filename,
            package: discriminator.namespace ?? "UNKNOWN",
            includeGeneratedComment: includeGeneratedComment
        )

        appendDiscriminator(discriminator, sources, framework, currentNamespace: discriminator.namespace)

        append()

        resolveImportsPlaceholder()
    }

    func appendDiscriminator(
        _ discriminator: Relax.Source.Discriminator,
        _ sources: Relax.Source.Sources,
        _ framework: Platform.KotlinFramework,
        currentNamespace: String?
    ) {
        if framework == .kotlinx {
            importPackage("kotlinx.serialization.Serializable")
            append("@Serializable")
            importPackage("kotlinx.serialization.json.JsonClassDiscriminator")
            append("@JsonClassDiscriminator(\"\(discriminator.discriminatorPropertyName)\")")
        }

        append("sealed class \(discriminator.name)(")
        indent {
            append("val \(discriminator.discriminatorPropertyName): \(discriminator.enumeration.name)")
        }
        append(")") {

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
                                property.value = property.value
                                return property
                            } else {
                                return property
                            }
                        }
                        innerStructures.append(innerStructure)
                    }
                }
            }

            let sharedProperties = innerStructures.sharedProperties()

            appendSharedDiscriminatorProperties(discriminator, framework, sharedProperties)

            appendEnumeration(discriminator.enumeration, framework)

            for innerStructure in innerStructures {
                append()
                appendStructure(innerStructure, sources, framework, discriminator: discriminator, sharedProperties: sharedProperties, currentNamespace: currentNamespace)
            }
        }
    }

    func appendSharedDiscriminatorProperties(
        _: Relax.Source.Discriminator,
        _ framework: Platform.KotlinFramework,
        _ sharedProperties: [Relax.Source.Property]
    ) {
        let abstractProperties = sharedProperties
//            .filter { $0.name != discriminator.discriminatorProperty.name }

        for property in abstractProperties {
            let name = property.name
            let type = property.type.kotlinName(for: framework)
            let isOptional = property.isOptional ? "?" : ""
            append("abstract val \(name): \(type)\(isOptional)")
        }
        if !abstractProperties.isEmpty {
            append()
        }
    }
}
