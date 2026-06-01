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
import OpenAPIKit

extension JSONSchema {
    var propertyType: PropertyType? {
        if isBoolean {
            return .stock(.bool)
        } else if isInteger {
            switch formatString {
            case "int32": return .stock(.int32)
            case "int64": return .stock(.int64)
            default: return .stock(.int)
            }
        } else if isNumber {
            switch formatString {
            case "double": return .stock(.double)
            case "float": return .stock(.float)
            default: return .stock(.double)
            }
        } else if isString {
            switch formatString {
            case "date": return .stock(.date)
            case "date-time": return .stock(.date)
            default: return .stock(.string)
            }
        } else if let schemaName = reference?.name {
            return .schema(PropertyType.Schema(
                name: schemaName,
                schemaName: schemaName
            ))
        } else if subschemas.count == 1 {
            return subschemas.first!.propertyType
        } else if subschemas.count == 2, subschemas.second!.isNull {
            return subschemas.first!.propertyType
        }

        return .unknown
    }
}
