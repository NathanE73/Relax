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
            mapping: relaxMapping(),
            sharedProperties: relaxSharedProperties(),
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

    func relaxMapping() -> [Relax.Discriminator.Mapping] {
        mapping.map { mapping in
            Relax.Discriminator.Mapping(
                value: mapping.value,
                type: SwiftNaming.name(from: mapping.name),
                name: mapping.name
            )
        }
    }

    func relaxSharedProperties() -> [Relax.Discriminator.SharedProperty] {
        if sharedProperties.isEmpty {
            let structures = mapping.map(\.schemaName).compactMap { schemaName in
                globalStructures.firstWith(namespace: nil, schemaName: schemaName)
            }
            let sharedProperties = structures.sharedProperties
            return sharedProperties.map { property in
                Relax.Discriminator.SharedProperty(
                    name: property.name,
                    type: property.type.propertyType,
                    typeNamespace: property.typeNamespace,
                    collectionType: property.collectionType,
                    isOptional: property.isOptional
                )
            }
        } else {
            return sharedProperties.map { property in
                Relax.Discriminator.SharedProperty(
                    name: property.name,
                    type: property.type.propertyType,
                    typeNamespace: property.typeNamespace,
                    collectionType: property.collectionType,
                    isOptional: property.isOptional
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
                structure.name = SwiftNaming.name(from: mapping.name)
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
