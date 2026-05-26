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

extension Component {
    struct Structure: FullyQualifiedName {
        var existing: Bool

        var schemaName: String?
        var namespace: String?
        var name: String
        var codable: CodableProtocol?

        var identifiablePropertyName: String?
        var properties: [Component.Property]
    }
}

extension [Component.Structure] {
    func firstWith(
        namespace: String?,
        schemaName: String
    ) -> Element? {
        // matching on schema name
        let matchingSchemaName = filter {
            $0.schemaName == schemaName
        }

        // matching on namespace
        if let namespace, let result = (matchingSchemaName.filter {
            $0.namespace == namespace
        }.only) {
            return result
        }

        // having a namespace
        if let result = (matchingSchemaName.filter {
            $0.namespace != namespace &&
                $0.namespace != nil
        }.only) {
            return result
        }

        // not having a namespace
        if let result = (matchingSchemaName.filter {
            $0.namespace == nil
        }.only) {
            return result
        }

        return nil
    }
}

extension [Component.Structure] {
    var sharedProperties: [Component.SharedProperty] {
        guard let firstStructure = first else { return [] }

        let otherStructures = dropFirst()

        return firstStructure.properties.reduce(into: []) { result, property in
            let sharedProperty = Component.SharedProperty(property)

            for otherStructure in otherStructures {
                guard let otherProperty = otherStructure.properties.firstWith(name: property.name)
                else { return }
                let otherSharedProperty = Component.SharedProperty(otherProperty)
                guard sharedProperty == otherSharedProperty
                else { return }
            }

            result.append(sharedProperty)
        }
    }
}
