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

class SwiftSource: Source {
    func appendHeading(
        filename: String,
        imports: [String] = [],
        publicImports: [String] = [],
        includeGeneratedComment: Bool,
        includeBundle: Bool = false
    ) {
        if includeGeneratedComment {
            appendHeaderComment(filename: filename)
        }

        for module in imports {
            append("import \(module)")
        }

        append()

        if !publicImports.isEmpty {
            append("#if hasFeature(InternalImportsByDefault)")
            indent {
                for module in publicImports {
                    append("public import \(module)")
                }
            }
            append("#else")
            indent {
                for module in publicImports {
                    append("import \(module)")
                }
            }
            append("#endif")
        }

        append()

        if includeBundle {
            append("private let bundle: Bundle = {")
            indent {
                append("#if SWIFT_PACKAGE")
                indent {
                    append("Bundle.module")
                }
                append("#else")
                indent {
                    append("class Object: NSObject {}")
                    append("return Bundle(for: Object.self)")
                }
                append("#endif")
            }
            append("}()")
            append()
        }
    }
}
