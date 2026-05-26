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

extension Component.Discriminator {
    func relaxComponent() -> Relax.Component? {
        guard let namespace else { return nil }

        return .discriminator(
            relaxDiscriminator(
                namespace: namespace
            )
        )
    }

    func relaxDiscriminator(
        namespace discriminatorNamespace: String
    ) -> Relax.Discriminator {
        Relax.Discriminator(
            namespace: discriminatorNamespace,
            name: name,
            codable: codable ?? .codable,
            discriminatorProperty: relaxDiscriminatorProperty(),
            mapping: relaxMapping(namespace: discriminatorNamespace),
            discriminators: [],
            enumerations: [relaxEnumeration()],
            structures: relaxStructures(namespace: discriminatorNamespace)
        )
    }

    func relaxDiscriminatorProperty() -> Relax.Discriminator.DiscriminatorProperty {
        Relax.Discriminator.DiscriminatorProperty(
            name: discriminatorProperty.name,
            type: discriminatorProperty.type
        )
    }

    func relaxMapping(
        namespace discriminatorNamespace: String
    ) -> [Relax.Discriminator.Mapping] {
        mapping.map {
            if let structure = globalStructures.firstWith(namespace: discriminatorNamespace, schemaName: $0.schemaName) {
                Relax.Discriminator.Mapping(
                    value: $0.value,
                    type: structure.name,
                    name: $0.name
                )
            } else {
                Relax.Discriminator.Mapping(
                    value: $0.value,
                    type: $0.value,
                    name: $0.name
                )
            }
        }
    }

    func relaxEnumeration() -> Relax.Enumeration {
        enumeration.relaxEnumeration(
            namespace: fullyQualifiedName
        )
    }

    func relaxStructures(
        namespace discriminatorNamespace: String
    ) -> [Relax.Structure] {
        mapping.compactMap { mapping in
            if var structure = globalStructures.firstWith(namespace: discriminatorNamespace, schemaName: mapping.schemaName), structure.namespace == nil {
                structure.codable = codable
                structure.name = structure.name
                return structure.relaxStructure(
                    namespace: fullyQualifiedName,
                    discriminatorProperty: Component.Structure.DiscriminatorProperty(
                        name: discriminatorProperty.name,
                        type: discriminatorProperty.type,
                        value: mapping.name
                    )
                )
            }
            return nil
        }
    }
}
