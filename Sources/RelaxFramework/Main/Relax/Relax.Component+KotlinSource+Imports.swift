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

extension Relax.Component {
    func konlinImports(
        _ framework: Platform.KotlinFramework,
        namespace componentNamespace: String
    ) -> [String] {
        var imports: Set<String> = []

        switch self {
        case let .enumeration(enumeration):
            enumeration.konlinImports(&imports, framework)
        case let .discriminator(discriminator):
            discriminator.konlinImports(&imports, framework)
        case let .structure(structure):
            structure.konlinImports(&imports, framework, namespace: componentNamespace)
        }

        for enumeration in allChildEnumerations {
            enumeration.konlinImports(&imports, framework)
        }

        for discriminator in allChildDiscriminators {
            discriminator.konlinImports(&imports, framework)
        }

        for structure in allChildStructures {
            structure.konlinImports(&imports, framework, namespace: componentNamespace)
        }

        return imports.sorted()
    }
}
