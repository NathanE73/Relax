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

extension SwiftSource {
    func appendProperty(
        _ property: Relax.Source.Property,
        currentNamespace: String?
    ) {
        // append("/// \(property.type)")

        if let value = property.value {
            switch property.type {
            case let .schema(schema):
                let type = schema.name
                let objectValue = escapeKeyword(value)
                append("let \(property.name) = \(type).\(objectValue)")
            case .stock(.string):
                append("let \(property.name) = \"\(value)\"")
            default:
                append("let \(property.name) = \(value)")
            }
        } else {
            let type = if case let .schema(schema) = property.type {
                if let namespace = schema.namespace, namespace != currentNamespace {
                    "\(namespace).\(schema.name)"
                } else {
                    schema.name
                }
            } else {
                property.type.swiftName
            }

            let isOptional = property.isOptional ? "?" : ""

            switch property.collectionType {
            case .array:
                append("var \(property.name): [\(type)]\(isOptional)")
            case nil:
                append("var \(property.name): \(type)\(isOptional)")
            }
        }
    }

    func appendIdentifiableProperty(_ property: Relax.Source.Property) {
        guard property.value == nil else { return }

        let type = property.type.swiftName
        let isOptional = property.isOptional ? "?" : ""
        append("var id: \(type)\(isOptional)") {
            append("\(property.name)")
        }
    }
}
