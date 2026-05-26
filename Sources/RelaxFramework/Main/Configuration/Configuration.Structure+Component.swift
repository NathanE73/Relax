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
import OpenAPIKit

extension Configuration.Structure {
    func componentStructure(
        document: OpenAPIKit.OpenAPI.Document
    ) -> Component.Structure? {
        guard let schema = document.components.schemas[.init(stringLiteral: schemaName)] else {
            return nil
        }

        guard schema.isObject, let objectContext = schema.objectContext else {
            return nil
        }

        return Component.Structure(
            existing: existing,
            schemaName: schemaName,
            namespace: namespace,
            name: name,
            codable: codable,
            identifiablePropertyName: identifiablePropertyName,
            properties: componentProperties(properties: objectContext.properties)
        )
    }

    // TODO: review
    func componentProperties(properties: OrderedDictionary<String, JSONSchema>) -> [Component.Property] {
        properties.compactMap {
            let property = self.properties.firstWith(name: $0.key)
            if property?.discard == true { return nil }
            let propertyName = $0.key
            let value = $0.value

            var propertyType = property?.type?.propertyType ?? value.propertyType ?? .unknown

            var propertyTypeNamespace: String?
            let propertyCollectionType: CollectionType? = value.isArray ? .array : nil
            var propertyValue: String?

            if let discriminator = value.discriminator, let mappingValues = discriminator.mapping?.values {
                something1(
                    propertyName: propertyName,
                    propertyType: &propertyType,
                    propertyTypeNamespace: &propertyTypeNamespace,
                    discriminator: discriminator,
                    mappingValues: mappingValues,
                    value: value
                )
            } else if let allowedValues = value.allowedValues {
                something2(
                    propertyName: propertyName,
                    propertyType: &propertyType,
                    propertyTypeNamespace: &propertyTypeNamespace,
                    propertyValue: &propertyValue,
                    allowedValues: allowedValues
                )
            } else if value.isArray, let allowedValues = value.subschemas.first?.allowedValues {
                something3(
                    propertyName: propertyName,
                    propertyType: &propertyType,
                    propertyTypeNamespace: &propertyTypeNamespace,
                    allowedValues: allowedValues
                )
            } else if case let .object(object) = propertyType {
                something4(
                    propertyType: &propertyType,
                    object: object
                )
            }

            return Component.Property(
                name: propertyName,
                type: propertyType,
                typeNamespace: propertyTypeNamespace,
                collectionType: propertyCollectionType,
                isOptional: value.nullable,
                value: propertyValue
            )
        }
    }

    func something1(
        propertyName: String,
        propertyType: inout Component.PropertyType,
        propertyTypeNamespace: inout String?,
        discriminator: OpenAPI.Discriminator,
        mappingValues: [String],
        value: JSONSchema
    ) {
        let structureNames = Set(mappingValues.map { String($0.split(separator: "/").last ?? "UNKNOWN") })
        if let discriminator = globalDiscriminators.firstWith(
            namespace: namespace,
            discriminatorPropertyName: discriminator.propertyName,
            structureNames: structureNames
        ) {
            propertyType = .discriminator(discriminator)
            propertyTypeNamespace = discriminator.namespace
        } else {
            var somethingName = propertyName.firstCharacterUppercased // TODO: SwiftNaming.
            if somethingName.hasSuffix("s"), value.isArray { // TODO: how to handle plural naming?
                somethingName = String(somethingName.dropLast(1))
            }

            let something = Component.Discriminator(
                existing: false,
                name: somethingName,
                codable: codable,
                discriminatorProperty: Component.Discriminator.DiscriminatorProperty(
                    name: discriminator.propertyName,
                    type: discriminator.propertyName.firstCharacterUppercased // TODO: SwiftNaming.
                ),
                mapping: discriminator.mapping?.map { key, value in
                    Component.Discriminator.Mapping(
                        value: key.description,
                        schemaName: String(value.split(separator: "/").last ?? "UNKNOWN"),
                        name: key.description
                    )
                } ?? [],
                enumeration: Component.Enumeration(
                    existing: false,
                    schemaName: nil,
                    name: discriminator.propertyName.firstCharacterUppercased, // TODO: SwiftNaming.
                    codable: codable,
                    mapping: discriminator.mapping?.map { key, _ in
                        Component.Enumeration.Mapping(
                            value: key.description,
                            name: key.description
                        )
                    } ?? []
                ),
                sharedProperties: [] // TODO: ...
            )
            propertyType = .discriminator(something)
        }
    }

    func something2(
        propertyName: String,
        propertyType: inout Component.PropertyType,
        propertyTypeNamespace: inout String?,
        propertyValue: inout String?,
        allowedValues: [AnyCodable]
    ) {
        if allowedValues.count == 1 {
            propertyValue = "\"\(allowedValues.first?.description ?? "")\""
        } else if let enumeration = globalEnumerations.firstWith(
            values: Set(allowedValues.map(\.description))
        ) {
            propertyType = .enumeration(enumeration)
            propertyTypeNamespace = enumeration.namespace
        } else {
            propertyType = .enumeration(Component.Enumeration(
                existing: false,
                schemaName: nil,
                name: propertyName.firstCharacterUppercased, // TODO: SwiftNaming.
                codable: codable,
                mapping: allowedValues.map(\.description).filter { $0 != "nil" }.map {
                    let adjustment = self.properties.firstWith(name: propertyName)?.values.firstWith(value: $0)
                    return Component.Enumeration.Mapping(
                        value: $0,
                        name: adjustment?.name ?? $0
                    )
                }
            ))
        }
    }

    func something3(
        propertyName: String,
        propertyType: inout Component.PropertyType,
        propertyTypeNamespace: inout String?,
        allowedValues: [AnyCodable]
    ) {
        var somethingName = propertyName.firstCharacterUppercased // TODO: SwiftNaming.
        if somethingName.hasSuffix("s") { // TODO: how to handle plural naming?
            somethingName = String(somethingName.dropLast(1))
        }

        if let enumeration = globalEnumerations.firstWith(
            values: Set(allowedValues.map(\.description))
        ) {
            propertyType = .enumeration(enumeration)
            propertyTypeNamespace = enumeration.namespace
        } else {
            propertyType = .enumeration(Component.Enumeration(
                existing: false,
                name: somethingName.firstCharacterUppercased, // TODO: SwiftNaming.
                codable: codable,
                mapping: allowedValues.map(\.description).filter { $0 != "nil" }.map {
                    let adjustment = self.properties.firstWith(name: propertyName)?.values.firstWith(value: $0)
                    return Component.Enumeration.Mapping(
                        value: $0,
                        name: adjustment?.name ?? $0
                    )
                }
            ))
        }
    }

    func something4(
        propertyType: inout Component.PropertyType,
        object: String
    ) {
        if let enumeration = globalEnumerations.firstWith(namespace: nil, schemaName: object) {
            propertyType = .enumeration(enumeration)
        }
    }
}
