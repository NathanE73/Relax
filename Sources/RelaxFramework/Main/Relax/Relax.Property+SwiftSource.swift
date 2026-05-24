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
    func appendProperty(_ property: Relax.Property, currentNamespace: String?) {
        if let value = property.value {
            switch property.type {
            case let .object(object):
                let objectValue = SwiftNaming.escapeKeyword(SwiftNaming.methodName(from: value))
                append("let \(property.name) = \(object).\(objectValue)")
            default:
                append("let \(property.name) = \(value)")
            }
        } else {
            let type = property.type.swiftName
            let isOptional = property.isOptional ? "?" : ""

            switch property.collectionType {
            case .array:
                if let typeNamespace = property.typeNamespace, typeNamespace != currentNamespace {
                    append("var \(property.name): [\(typeNamespace).\(type)]\(isOptional)")
                } else {
                    append("var \(property.name): [\(type)]\(isOptional)")
                }
            case nil:
                if let typeNamespace = property.typeNamespace, typeNamespace != currentNamespace {
                    append("var \(property.name): \(typeNamespace).\(type)\(isOptional)")
                } else {
                    append("var \(property.name): \(type)\(isOptional)")
                }
            }
        }
    }

    func appendIdentifiableProperty(_ property: Relax.Property) {
        guard property.value == nil else { return }

        let type = property.type.swiftName
        let isOptional = property.isOptional ? "?" : ""
        append("var id: \(type)\(isOptional)") {
            append("\(property.name)")
        }
    }
}
