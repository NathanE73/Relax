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
    func appendStructures(
        _ structures: [Relax.Structure],
        discriminator: Relax.Discriminator?,
        currentNamespace: String?
    ) {
        for structure in structures {
            appendStructure(structure, discriminator: discriminator, currentNamespace: currentNamespace)
            append()
        }
    }

    func appendStructure(
        _ structure: Relax.Structure,
        discriminator: Relax.Discriminator?,
        currentNamespace: String?
    ) {
        let isIdentifiable = structure.identifiablePropertyName != nil ||
            structure.properties.firstWith(name: "id") != nil

        let protocols = ([
            structure.codable.swiftName,
            "Equatable",
            isIdentifiable ? "Identifiable" : nil,
        ] as [String?])
            .compactMap(\.self)
            .joined(separator: ", ")

        append("struct \(structure.name): \(protocols)") {
            if let propertyName = structure.identifiablePropertyName {
                if let identifiableProperty = structure.properties.first(where: { $0.name == propertyName }) {
                    appendIdentifiableProperty(identifiableProperty)
                    append()
                }
            }

            for property in structure.properties {
                if let discriminator, discriminator.codable.isDecodable, discriminator.discriminatorProperty.name == property.name {
                    continue
                }
                appendProperty(property, currentNamespace: currentNamespace)
            }

            append()

            appendDiscriminators(structure.discriminators, currentNamespace: currentNamespace)
            appendEnumerations(structure.enumerations)
            appendStructures(structure.structures, discriminator: nil, currentNamespace: currentNamespace)
        }
    }
}
