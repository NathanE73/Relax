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

extension Relax.Source {
    struct Discriminator {
        var existing: Bool

        var schemaName: String?
        var namespace: String?
        var name: String
        var codable: CodableProtocol

        var discriminatorPropertyName: String
        var mapping: [Mapping]
        var enumeration: Enumeration

        struct DiscriminatorProperty {
            var name: String
            var type: String
        }

        struct Mapping {
            var value: String
            var schemaName: String
            var name: String
        }
    }
}

extension Relax.Source.Discriminator {
    init?(
        configuration: Relax.Configuration.Discriminator?,
        schema: Relax.Schema.Discriminator
    ) {
        self.init(
            existing: configuration?.existing ?? false,
            schemaName: schema.schemaName,
            namespace: configuration?.namespace,
            name: configuration?.name ?? schema.schemaName,
            codable: configuration?.codable ?? .codable,
            discriminatorPropertyName: schema.discriminatorPropertyName,
            mapping: schema.mapping.map {
                let mapping = configuration?.mapping?.firstWith(value: $0.value)
                return Relax.Source.Discriminator.Mapping(
                    value: $0.value,
                    schemaName: $0.schemaName,
                    name: mapping?.name ?? $0.value.firstCharacterUppercased // TODO: ...
                )
            },
            enumeration: Relax.Source.Enumeration(
                existing: false,
                schemaName: nil,
                namespace: nil,
                name: schema.discriminatorPropertyName.firstCharacterUppercased, // TODO: ...
                codable: configuration?.codable ?? .codable,
                mapping: schema.mapping.map {
                    let mapping = configuration?.mapping?.firstWith(value: $0.value)
                    return Relax.Source.Enumeration.Mapping(
                        value: $0.value,
                        name: mapping?.name ?? $0.value.firstCharacterLowercased // TODO: ...
                    )
                }
            )
        )
    }
}

extension Relax.Source.Discriminator {
    init?(
        configuration: Relax.Configuration.Discriminator,
        schema: Relax.Schema.Structure
    ) {
        guard let propertyName = configuration.propertyName else { return nil }

        guard let property = schema.properties.firstWith(name: propertyName) else { return nil }

        guard case let .discriminator(discriminator) = property.type else { return nil }

        self.init(
            existing: configuration.existing,
            schemaName: nil,
            namespace: configuration.namespace,
            name: configuration.name,
            codable: configuration.codable ?? .codable,
            discriminatorPropertyName: property.name,
            mapping: discriminator.mapping.map {
                let mapping = configuration.mapping?.firstWith(value: $0.value)
                return Relax.Source.Discriminator.Mapping(
                    value: $0.value,
                    schemaName: $0.schemaName,
                    name: mapping?.name ?? $0.value.firstCharacterUppercased // TODO: ...
                )
            },
            enumeration: Relax.Source.Enumeration(
                existing: false,
                schemaName: nil,
                namespace: nil,
                name: discriminator.discriminatorPropertyName.firstCharacterUppercased, // TODO: ...
                codable: configuration.codable ?? .codable,
                mapping: discriminator.mapping.map {
                    let mapping = configuration.mapping?.firstWith(value: $0.value)
                    return Relax.Source.Enumeration.Mapping(
                        value: $0.value,
                        name: mapping?.name ?? $0.value.firstCharacterLowercased // TODO: ...
                    )
                }
            )
        )
    }
}

extension [Relax.Source.Discriminator] {
    func firstWith(schemaName: String) -> Element? {
        filter {
            $0.schemaName == schemaName
        }.only
    }
}
