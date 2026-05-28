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

extension Relax.Configuration {
    struct Structure {
        var existing: Bool

        var schemaName: String
        var namespace: String?
        var name: String
        var codable: CodableProtocol?

        var identifiablePropertyName: String?
        var properties: [Property]

        struct Property {
            var name: String
            var type: PropertyType?
            var discard: Bool
            var values: [Value]

            struct Value {
                var value: String
                var name: String
            }
        }
    }
}

extension Relax.Configuration.Structure {
    init(
        namespace: RelaxConfiguration.Namespace?,
        structure: RelaxConfiguration.Structure,
        addNamePrefix: (_ name: String) -> String
    ) {
        self.init(
            existing: structure.existing ?? false,
            schemaName: structure.schema,
            namespace: namespace?.namespace,
            name: addNamePrefix(structure.name ?? structure.schema),
            codable: namespace?.codable ?? .codable,
            identifiablePropertyName: structure.identifiablePropertyName,
            properties: structure.properties?.compactMap(Property.init) ?? []
        )
    }
}

extension Relax.Configuration.Structure.Property {
    init?(property: RelaxConfiguration.Structure.Property) {
        self.init(
            name: property.name,
            type: property.type == nil ? nil : .object(property.type!),
            discard: property.discard ?? false,
            values: property.values?.compactMap(Value.init) ?? []
        )
    }
}

extension Relax.Configuration.Structure.Property.Value {
    init?(value: RelaxConfiguration.Structure.Property.Value) {
        guard let name = value.name else { return nil }
        self.init(
            value: value.value,
            name: name
        )
    }
}
