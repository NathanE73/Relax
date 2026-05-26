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
    func appendStructures(
        _ structures: [Relax.Structure],
        _ framework: Platform.KotlinFramework,
        discriminator: Relax.Discriminator?,
        sharedProperties: [Relax.Discriminator.SharedProperty]
    ) {
        for structure in structures {
            appendStructure(structure, framework, discriminator: discriminator, sharedProperties: sharedProperties)
            append()
        }
    }

    func appendStructure(
        _ structure: Relax.Structure,
        _ framework: Platform.KotlinFramework,
        discriminator: Relax.Discriminator?,
        sharedProperties: [Relax.Discriminator.SharedProperty]
    ) {
        switch framework {
        case .kotlinx:
            append("@Serializable")
            if let discriminator {
                let property = structure.properties.firstWith(name: discriminator.discriminatorProperty.name)
                let propertyValue = property?.value ?? "UNKNOWN"
                append("@SerialName(\"\(propertyValue)\")")
            }
        case .moshi:
            append("@JsonClass(generateAdapter = true)")
        }

        append("data class \(structure.name)(")
        indent {
            let sharedPropertyNames = sharedProperties.map(\.name)

            for property in structure.properties {
                if let discriminator, discriminator.discriminatorProperty.name == property.name {
                    continue
                }

                let override = sharedPropertyNames.contains(property.name)
                appendProperty(property, framework, override: override)
            }

            removeLastBlankLine()
            removeTrailingComma()

            append()
            if discriminator != nil {
                appendStructures(structure.structures, framework, discriminator: nil, sharedProperties: [])
            }
        }

        if let discriminator {
            let property = structure.properties.firstWith(name: discriminator.discriminatorProperty.name)
            let propertyValue = switch framework {
            case .kotlinx:
                KotlinNaming.name(from: property?.value ?? "UNKNOWN")
            case .moshi:
                KotlinNaming.caseName(from: property?.value ?? "UNKNOWN")
            }
            append(") : \(discriminator.name)(\(discriminator.discriminatorProperty.type).\(propertyValue))")
        } else {
            if structure.enumerations.isEmpty, structure.discriminators.isEmpty {
                append(")")
            } else {
                append(")") {
                    appendEnumerations(structure.enumerations, framework)
                    appendDiscriminators(structure.discriminators, framework)
                }
            }
        }

        append()
        if discriminator == nil {
            appendStructures(structure.structures, framework, discriminator: nil, sharedProperties: [])
        }
    }
}
