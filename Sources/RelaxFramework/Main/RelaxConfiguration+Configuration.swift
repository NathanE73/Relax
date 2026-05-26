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

extension RelaxConfiguration {
    func kotlinMoshiConfiguration() -> Configuration.KotlinMoshi? {
        kotlinMoshi.map { kotlin in
            Configuration.KotlinMoshi(
                adapters: kotlin.adapters.map { adapters in
                    Configuration.KotlinMoshi.Adapters(
                        namespace: adapters.namespace,
                        mapping: adapters.mapping.map { mapping in
                            Configuration.KotlinMoshi.Adapters.Mapping(
                                name: addNamePrefix(mapping.name),
                                namespace: mapping.namespace
                            )
                        }
                    )
                }
            )
        }
    }

    func discriminatorConfigurations() -> [Configuration.Discriminator] {
        namespaces.flatMap { namespace in
            namespace.discriminators?.map { discriminator in
                Configuration.Discriminator(
                    existing: discriminator.existing ?? false,
                    schemaName: discriminator.schema,
                    namespace: namespace.namespace,
                    name: addNamePrefix(discriminator.name ?? discriminator.schema),
                    codable: namespace.codable ?? .codable,
                    propertyName: discriminator.propertyName,
                    mapping: discriminator.mapping?.compactMap { mapping in
                        if let name = mapping.name {
                            Configuration.Discriminator.Mapping(
                                value: mapping.value,
                                name: name
                            )
                        } else {
                            nil
                        }
                    } ?? []
                )
            } ?? []
        }
    }

    func enumerationConfigurations() -> [Configuration.Enumeration] {
        namespaces.flatMap { namespace in
            namespace.enumerations?.map { enumeration in
                Configuration.Enumeration(
                    existing: enumeration.existing ?? false,
                    schemaName: enumeration.schema,
                    namespace: namespace.namespace,
                    name: addNamePrefix(enumeration.name ?? enumeration.schema),
                    codable: namespace.codable ?? .codable,
                    propertyName: enumeration.propertyName,
                    mapping: enumeration.mapping?.compactMap { mapping in
                        if let name = mapping.name {
                            Configuration.Enumeration.Mapping(
                                value: mapping.value,
                                name: name
                            )
                        } else {
                            nil
                        }
                    } ?? []
                )
            } ?? []
        }
    }

    func structureConfigurations() -> [Configuration.Structure] {
        func something(_ structure: Structure, namespace: String?, codable: CodableProtocol?) -> Configuration.Structure {
            Configuration.Structure(
                existing: structure.existing ?? false,
                schemaName: structure.schema,
                namespace: namespace,
                name: addNamePrefix(structure.name ?? structure.schema),
                codable: codable,
                identifiablePropertyName: structure.identifiablePropertyName,
                properties: structure.properties?.compactMap { property in
                    Configuration.Structure.Property(
                        name: property.name,
                        type: property.type == nil ? nil : .object(property.type!),
                        discard: property.discard ?? false,
                        values: property.values?.compactMap { value in
                            if let name = value.name {
                                Configuration.Structure.Property.Value(
                                    value: value.value,
                                    name: name
                                )
                            } else {
                                nil
                            }
                        } ?? []
                    )
                } ?? []
            )
        }

        let namespaceConfigurations = namespaces.flatMap { namespace in
            namespace.structures?.map { structure in
                something(structure, namespace: namespace.namespace, codable: namespace.codable ?? .codable)
            } ?? []
        }

        let modificationConfigurations = modifications?.structures?.map { structure in
            something(structure, namespace: nil, codable: nil)
        } ?? []

        return namespaceConfigurations + modificationConfigurations
    }
}
