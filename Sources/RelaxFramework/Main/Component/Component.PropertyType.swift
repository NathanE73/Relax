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

extension Component {
    enum PropertyType {
        case boolean
        case int
        case int32
        case int64
        case float
        case double
        case date
        case string
        case object(String)
        case discriminator(Discriminator)
        case enumeration(Enumeration)

        static let unknown = PropertyType.object("UNKNOWN")
    }
}

extension Component.PropertyType {
    var schemaName: String? {
        switch self {
        case .boolean: nil
        case .int: nil
        case .int32: nil
        case .int64: nil
        case .float: nil
        case .double: nil
        case .date: nil
        case .string: nil
        case let .object(object): object
        case let .discriminator(discriminator): discriminator.name
        case let .enumeration(enumeration): enumeration.name
        }
    }

    var propertyType: PropertyType {
        switch self {
        case .boolean: .bool
        case .int: .int
        case .int32: .int32
        case .int64: .int64
        case .float: .float
        case .double: .double
        case .date: .date
        case .string: .string
        case let .object(object): .object(object)
        case let .discriminator(discriminator): .object(discriminator.name)
        case let .enumeration(enumeration): .object(enumeration.name)
        }
    }
}

extension PropertyType {
    var propertyType: Component.PropertyType {
        switch self {
        case .bool: .boolean
        case .int: .int
        case .int32: .int32
        case .int64: .int64
        case .float: .float
        case .double: .double
        case .date: .date
        case .string: .string
        case let .object(object): .object(object)
        }
    }
}

extension JSONSchema {
    var propertyType: Component.PropertyType? {
        if isArray {
            if let schemaName = arrayContext?.items?.propertyType?.schemaName {
                return .object(schemaName)
            }
        } else if isBoolean {
            return .boolean
        } else if isInteger {
            switch formatString {
            case "int32": return .int32
            case "int64": return .int64
            default: return .int
            }
        } else if isNumber {
            switch formatString {
            case "double": return .double
            case "float": return .float
            default: return .double
            }
        } else if isString {
            switch formatString {
            case "date": return .date
            case "date-time": return .date
            default: return .string
            }
        } else if let object = reference?.name {
            return .object(object)
        } else {
            if subschemas.count == 1 {
                return subschemas.first!.propertyType
            } else if subschemas.count == 2, subschemas.second!.isNull {
                return subschemas.first!.propertyType
            }
        }

        return .unknown
    }
}
