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
    struct Structure {
        var existing: Bool

        var schemaName: String?
        var namespace: String?
        var name: String
        var codable: CodableProtocol

        var identifiablePropertyName: String?
        var properties: [Component.Property] // TODO: `Component` ?
    }
}

extension Relax.Source.Structure {
    init?(
        configuration: Relax.Configuration.Structure,
        schema: Relax.Schema.Structure
    ) {
        self.init(
            existing: configuration.existing,
            schemaName: schema.schemaName,
            namespace: configuration.namespace,
            name: configuration.name,
            codable: configuration.codable ?? .codable,
            identifiablePropertyName: configuration.identifiablePropertyName,
            properties: schema.properties.compactMap {
                let property = configuration.properties.firstWith(name: $0.name)
                guard property?.discard != true else { return nil }
                return Component.Property(
                    name: $0.name,
                    type: property?.type?.propertyType ?? $0.type.propertyType,
                    typeNamespace: nil,
                    collectionType: $0.collectionType,
                    isOptional: $0.isOptional,
                    value: nil // TODO: ...
                )
            }
        )
    }
}
