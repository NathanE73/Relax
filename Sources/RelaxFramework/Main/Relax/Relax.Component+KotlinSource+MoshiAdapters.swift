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
    func appendMoshiDiscriminatorAdapter(
        relaxComponents: [Relax.Component],
        mappingName: String,
        namespace: String,
        filename: String,
        includeGeneratedComment: Bool
    ) {
        var imports = [
            "com.squareup.moshi.Moshi",
            "com.squareup.moshi.adapters.PolymorphicJsonAdapterFactory",
            "kotlin.jvm.java",
        ]

        imports.append(contentsOf: relaxComponents.map(\.fullyQualifiedName))

        appendHeading(
            filename: filename,
            package: namespace,
            imports: imports,
            includeGeneratedComment: includeGeneratedComment
        )

        append("fun Moshi.Builder.add\(mappingName)(): Moshi.Builder") {
            for relaxComponent in relaxComponents {
                if let discriminator = relaxComponent.discriminator {
                    appendMoshiDiscriminatorAdapter(discriminator, parentStructureName: nil)
                } else if let structure = relaxComponent.structure {
                    appendMoshiDiscriminatorAdapters(structure.discriminators, parentStructureName: structure.name)
                }
            }

            append("return this")
        }

        append()
    }

    func appendMoshiDiscriminatorAdapters(
        _ discriminators: [Relax.Discriminator],
        parentStructureName: String?
    ) {
        for discriminator in discriminators {
            appendMoshiDiscriminatorAdapter(discriminator, parentStructureName: parentStructureName)
            append()
        }
    }

    func appendMoshiDiscriminatorAdapter(
        _ discriminator: Relax.Discriminator,
        parentStructureName: String?
    ) {
        let discriminatorName = if let parentStructureName {
            "\(parentStructureName).\(discriminator.name)"
        } else {
            discriminator.name
        }

        append("add(")
        indent {
            append("PolymorphicJsonAdapterFactory.of(\(discriminatorName)::class.java, \"\(discriminator.discriminatorProperty.name)\")")
            indent {
                for structure in discriminator.structures {
                    let discriminatorProperty = structure.properties.firstWith(name: discriminator.discriminatorProperty.name)
                    let discriminatorValue = KotlinNaming.caseName(from: discriminatorProperty?.value ?? "UNKNOWN")
                    append(".withSubtype(\(discriminatorName).\(structure.name)::class.java, \(discriminatorName).\(discriminator.discriminatorProperty.type).\(discriminatorValue).name)")
                }
            }
        }
        append(")")
        append()
    }
}
