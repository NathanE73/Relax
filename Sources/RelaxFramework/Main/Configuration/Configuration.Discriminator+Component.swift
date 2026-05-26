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

extension Configuration.Discriminator {
    func componentDiscriminator(
        document: OpenAPIKit.OpenAPI.Document
    ) -> Component.Discriminator? {
        guard let schema = document.components.schemas[.init(stringLiteral: schemaName)] else {
            return nil
        }

        if let discriminator = schema.discriminator {
            return Component.Discriminator(
                existing: existing,
                schemaName: schemaName,
                namespace: namespace,
                name: name,
                codable: codable,
                discriminatorProperty: componentDiscriminatorProperty(discriminator),
                mapping: componentMapping(discriminator),
                enumeration: componentEnumeration(discriminator)
            )
        }

        if schema.isObject, let objectContext = schema.objectContext {
            if let propertyName, let property = objectContext.properties[propertyName] {
                if let discriminator = property.discriminator {
                    return Component.Discriminator(
                        existing: existing,
                        schemaName: schemaName,
                        namespace: namespace,
                        name: name,
                        codable: codable,
                        discriminatorProperty: componentDiscriminatorProperty(discriminator),
                        mapping: componentMapping(discriminator),
                        enumeration: componentEnumeration(discriminator)
                    )
                }
            }
        }

        return nil
    }

    func componentDiscriminatorProperty(
        _ discriminator: OpenAPI.Discriminator
    ) -> Component.Discriminator.DiscriminatorProperty {
        Component.Discriminator.DiscriminatorProperty(
            name: discriminator.propertyName,
            type: SwiftNaming.name(from: discriminator.propertyName)
        )
    }

    func componentMapping(
        _ discriminator: OpenAPI.Discriminator
    ) -> [Component.Discriminator.Mapping] {
        discriminator.mapping?.map { key, value in
            let schemaName = String(value.split(separator: "/").last ?? "UNKNOWN")
            return Component.Discriminator.Mapping(
                value: schemaName,
                schemaName: schemaName,
                name: key
            )
        } ?? []
    }

    func componentEnumeration(
        _ discriminator: OpenAPI.Discriminator
    ) -> Component.Enumeration {
        Component.Enumeration(
            existing: false,
            name: SwiftNaming.name(from: discriminator.propertyName),
            codable: codable,
            mapping: discriminator.mapping?.map { key, _ in
                Component.Enumeration.Mapping(
                    value: key,
                    name: SwiftNaming.name(from: key)
                )
            } ?? []
        )
    }
}
