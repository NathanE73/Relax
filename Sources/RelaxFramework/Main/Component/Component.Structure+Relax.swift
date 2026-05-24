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

extension Component.Structure {
    struct DiscriminatorProperty {
        var name: String
        var type: String
        var value: String
    }

    func relaxComponent() -> Relax.Component? {
        guard let namespace else { return nil }

        return .structure(
            relaxStructure(
                namespace: namespace
            )
        )
    }

    func relaxStructure(
        namespace structureNamespace: String,
        discriminatorProperty: DiscriminatorProperty? = nil
    ) -> Relax.Structure {
        Relax.Structure(
            namespace: structureNamespace,
            name: name,
            codable: codable ?? .codable,
            identifiablePropertyName: identifiablePropertyName,
            properties: relaxProperties(namespace: structureNamespace, discriminatorProperty: discriminatorProperty),
            discriminators: relaxDiscriminators(),
            enumerations: relaxEnumerations(discriminatorProperty: discriminatorProperty),
            structures: relaxStructures(namespace: structureNamespace)
        )
    }

    func relaxProperties(
        namespace structureNamespace: String,
        discriminatorProperty: DiscriminatorProperty?
    ) -> [Relax.Property] {
        properties.compactMap { property in
            if let discriminatorProperty, discriminatorProperty.name == property.name {
                return Relax.Property(
                    name: discriminatorProperty.name,
                    type: .object(discriminatorProperty.type),
                    isOptional: false,
                    value: discriminatorProperty.value
                )
            }

            var propertyType = property.type.propertyType
            var propertyTypeNamespace = property.typeNamespace

            switch property.type {
            case .object:
                if propertyTypeNamespace == nil, let schemaName = property.type.schemaName {
                    if let structure = globalStructures.firstWith(namespace: structureNamespace, schemaName: schemaName) {
                        propertyType = .object(structure.name)
                        propertyTypeNamespace = structure.namespace
                    }
                }
            case let .enumeration(enumeration):
                propertyTypeNamespace = enumeration.namespace ?? propertyTypeNamespace
            default:
                break
            }

            return Relax.Property(
                name: property.name,
                type: propertyType,
                typeNamespace: propertyTypeNamespace,
                collectionType: property.collectionType,
                isOptional: property.isOptional,
                value: property.value
            )
        }
    }

    func relaxDiscriminators() -> [Relax.Discriminator] {
        properties.compactMap { property -> Relax.Discriminator? in
            if case let .discriminator(discriminator) = property.type, discriminator.namespace == nil {
                return discriminator.relaxDiscriminator(
                    namespace: fullyQualifiedName
                )
            }
            return nil
        }
    }

    func relaxEnumerations(
        discriminatorProperty: DiscriminatorProperty?
    ) -> [Relax.Enumeration] {
        properties.compactMap { property -> Relax.Enumeration? in
            if property.name != discriminatorProperty?.name {
                if case var .enumeration(enumeration) = property.type, enumeration.namespace == nil {
                    enumeration.codable = enumeration.codable ?? codable
                    return enumeration.relaxEnumeration(
                        namespace: fullyQualifiedName
                    )
                }
            }
            return nil
        }
    }

    func relaxStructures(
        namespace structureNamespace: String
    ) -> [Relax.Structure] {
        properties.uniqueSchemaNames.compactMap { schemaName -> Relax.Structure? in
            if var structure = globalStructures.firstWith(namespace: structureNamespace, schemaName: schemaName), structure.namespace == nil {
                structure.codable = structure.codable ?? codable
                return structure.relaxStructure(
                    namespace: fullyQualifiedName
                )
            } else {
                return nil
            }
        }
    }
}
