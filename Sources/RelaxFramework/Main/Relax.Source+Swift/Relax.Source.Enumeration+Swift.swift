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
    func appendEnumeration(
        _ enumeration: Relax.Source.Enumeration,
        filename: String,
        includeGeneratedComment: Bool
    ) {
        appendHeading(
            filename: filename,
            includeGeneratedComment: includeGeneratedComment
        )

        importPackage("Foundation")

        if let namespace = enumeration.namespace {
            append("extension \(namespace)") {
                appendEnumeration(enumeration)
            }
        } else {
            appendEnumeration(enumeration)
        }

        append()

        resolveImportsPlaceholder()
    }

    func appendEnumeration(
        _ enumeration: Relax.Source.Enumeration
    ) {
        let protocols = enumeration.codable.swiftName
        append("enum \(enumeration.name): String, \(protocols) {")

        indent {
            for mapping in enumeration.mapping {
                let name = escapeKeyword(mapping.name)
                if mapping.name != mapping.value {
                    append("case \(name) = \"\(mapping.value)\"")
                } else {
                    append("case \(name)")
                }
            }

            append()
        }

        append("}")
    }
}
