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
        document _: OpenAPIKit.OpenAPI.Document
    ) -> Component.Discriminator? {
        Component.Discriminator(
            existing: existing,
            namespace: namespace,
            name: name,
            codable: codable,
            discriminatorProperty: componentDiscriminatorProperty(),
            mapping: componentMapping(),
            enumeration: componentEnumeration()
        )
    }

    func componentDiscriminatorProperty() -> Component.Discriminator.DiscriminatorProperty {
        Component.Discriminator.DiscriminatorProperty(
            name: property.name,
            type: property.type
        )
    }

    func componentMapping() -> [Component.Discriminator.Mapping] {
        mapping.map {
            Component.Discriminator.Mapping(
                value: $0.value,
                schema: $0.schema,
                name: $0.name
            )
        }
    }

    func componentEnumeration() -> Component.Enumeration {
        Component.Enumeration(
            existing: false,
            name: property.type,
            codable: codable,
            mapping: mapping.map {
                Component.Enumeration.Mapping(
                    value: $0.value,
                    name: $0.name
                )
            }
        )
    }
}
