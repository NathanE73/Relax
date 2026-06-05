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

extension KotlinSource {
    func appendEnumeration(
        _ enumeration: Relax.Source.Enumeration,
        _ framework: Platform.KotlinFramework,
        filename: String,
        includeGeneratedComment: Bool
    ) {
        appendHeading(
            filename: filename,
            package: enumeration.namespace ?? "UNKNOWN",
            includeGeneratedComment: includeGeneratedComment
        )

        appendEnumeration(enumeration, framework)

        append()

        resolveImportsPlaceholder()
    }

    func appendEnumeration(
        _ enumeration: Relax.Source.Enumeration,
        _ framework: Platform.KotlinFramework
    ) {
        switch framework {
        case .kotlinx:
            importPackage("kotlinx.serialization.Serializable")
            append("@Serializable")
            append("enum class \(enumeration.name) {")
            indent {
                for mapping in enumeration.mapping {
                    let mappingName = escapeKeyword(mapping.name)
                    if mappingName != mapping.value {
                        importPackage("kotlinx.serialization.SerialName")
                        append("@SerialName(\"\(mapping.value)\")")
                    }
                    append("\(mappingName),")
                    if enumeration.requiresSerialNameImport {
                        append()
                    }
                }

                removeLastBlankLine()
                removeTrailingComma()
            }
            append("}")
        case .moshi:
            append("enum class \(enumeration.name)(val label: String) {")
            indent {
                for mapping in enumeration.mapping {
                    let mappingName = escapeKeyword(mapping.name)
                    importPackage("com.squareup.moshi.Json")
                    append("@Json(name = \"\(mapping.value)\")")
                    append("\(mappingName)(\"\(mapping.value)\"),")
                    append()
                }

                removeLastBlankLine()
                removeTrailingComma()
            }
            append("}")
        }
    }
}

extension Relax.Source.Enumeration {
    var requiresSerialNameImport: Bool {
        !mapping.allSatisfy { mapping in
            mapping.value == mapping.name
        }
    }
}
