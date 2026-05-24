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
    func appendDiscriminators(
        _ discriminators: [Relax.Discriminator],
        _ framework: Platform.KotlinFramework
    ) {
        for discriminator in discriminators {
            appendDiscriminator(discriminator, framework)
            append()
        }
    }

    func appendDiscriminator(
        _ discriminator: Relax.Discriminator,
        _ framework: Platform.KotlinFramework
    ) {
        if framework == .kotlinx {
            append("@Serializable")
            append("@JsonClassDiscriminator(\"\(discriminator.discriminatorProperty.name)\")")
        }

        append("sealed class \(discriminator.name)(")
        indent {
            append("val \(discriminator.discriminatorProperty.name): \(discriminator.discriminatorProperty.type)")
        }
        append(")") {
            let sharedPropertyNames = discriminator.structures.sharedPropertyNames

            appendSharedDiscriminatorProperties(discriminator, framework, sharedPropertyNames)

            appendEnumerations(discriminator.enumerations, framework)
            appendStructures(discriminator.structures, framework, discriminator: discriminator, sharedPropertyNames: sharedPropertyNames)
        }
    }

    func appendSharedDiscriminatorProperties(
        _ discriminator: Relax.Discriminator,
        _ framework: Platform.KotlinFramework,
        _ sharedPropertyNames: [String]
    ) {
        if let sharedProperties = discriminator.structures.first?.properties {
            let abstractProperties = sharedProperties
                .filter {
                    sharedPropertyNames.contains($0.name) &&
                        $0.name != discriminator.discriminatorProperty.name
                }
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
}
