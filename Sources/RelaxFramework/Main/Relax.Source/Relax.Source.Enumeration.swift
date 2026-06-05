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
    struct Enumeration: FullyQualifiedName {
        var existing: Bool

        var schemaName: String?
        var namespace: String?
        var name: String
        var codable: CodableProtocol

        var mapping: [Mapping]

        struct Mapping {
            var value: String
            var name: String
        }
    }
}

extension Relax.Source.Enumeration {
    init?(
        configuration: Relax.Configuration.Enumeration?,
        schema: Relax.Schema.Enumeration,
        naming: SourceNaming
    ) {
        self.init(
            existing: configuration?.existing ?? false,
            schemaName: schema.schemaName,
            namespace: configuration?.namespace,
            name: configuration?.name ?? schema.schemaName,
            codable: configuration?.codable ?? .codable,
            mapping: schema.values.map { value in
                let mapping = configuration?.mapping.firstWith(value: value)
                let name = mapping?.name ?? naming.caseName(value)
                return Mapping(
                    value: value,
                    name: name
                )
            }
        )
    }

    init?(
        configuration: Relax.Configuration.Enumeration,
        schema: Relax.Schema.Structure,
        naming: SourceNaming
    ) {
        guard let propertyName = configuration.propertyName else { return nil }

        guard let property = schema.properties.firstWith(name: propertyName) else { return nil }

        guard case let .enumeration(enumeration) = property.type else { return nil }

        self.init(
            existing: configuration.existing,
            schemaName: nil,
            namespace: configuration.namespace,
            name: configuration.name,
            codable: configuration.codable ?? .codable,
            mapping: enumeration.mapping.map {
                let mapping = configuration.mapping.firstWith(value: $0.value)
                let name = mapping?.name ?? naming.methodName($0.value)
                return Mapping(
                    value: $0.value,
                    name: name
                )
            }
        )
    }
}

extension Relax.Source.Enumeration {
    func name(forValue value: String?) -> String? {
        mapping.filter {
            $0.value == value
        }.only?.name
    }
}

extension [Relax.Source.Enumeration] {
    func firstWith(schemaName: String) -> Element? {
        filter {
            $0.schemaName == schemaName
        }.only
    }
}
