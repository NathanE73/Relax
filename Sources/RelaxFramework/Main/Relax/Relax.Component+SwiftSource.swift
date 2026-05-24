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
    func appendComponent(
        _ component: Relax.Component,
        filename: String,
        includeGeneratedComment: Bool
    ) {
        let allDiscriminators = [component.discriminator].compactMap(\.self) + component.allChildDiscriminators

        let imports = component.swiftImports(hasDiscriminators: !allDiscriminators.isEmpty)

        appendHeading(
            filename: filename,
            imports: imports,
            includeGeneratedComment: includeGeneratedComment
        )

        append("extension \(component.namespace)") {
            switch component {
            case let .discriminator(discriminator):
                appendDiscriminator(discriminator, currentNamespace: component.namespace)
            case let .enumeration(enumeration):
                appendEnumeration(enumeration)
            case let .structure(structure):
                appendStructure(structure, discriminator: nil, currentNamespace: component.namespace)
            }
        }

        append()

        for discriminator in allDiscriminators {
            if discriminator.codable.isDecodable {
                appendDecodableDiscriminator(discriminator)
                append()
            }

            if discriminator.codable.isEncodable {
                appendEncodableDiscriminator(discriminator)
                append()
            }
        }

        append()
    }
}
