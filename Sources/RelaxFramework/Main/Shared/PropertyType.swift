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

enum PropertyType: Equatable {
    case stock(Stock)
    case schema(Schema)
    case discriminator(Discriminator)
    case enumeration(Enumeration)
    case unknown

    enum Stock: Equatable {
        case bool
        case date
        case double
        case float
        case int
        case int32
        case int64
        case string
    }

    var name: String? {
        switch self {
        case .stock: nil
        case let .schema(schema): schema.name
        case let .discriminator(discriminator): discriminator.name
        case let .enumeration(enumeration): enumeration.name
        case .unknown: nil
        }
    }

    var schemaName: String? {
        switch self {
        case .stock: nil
        case let .schema(schema): schema.schemaName
        case let .discriminator(discriminator): discriminator.schemaName
        case let .enumeration(enumeration): enumeration.schemaName
        case .unknown: nil
        }
    }

    var namespace: String? {
        switch self {
        case .stock: nil
        case let .schema(schema): schema.namespace
        case let .discriminator(discriminator): discriminator.namespace
        case let .enumeration(enumeration): enumeration.namespace
        case .unknown: nil
        }
    }

    struct Schema: Equatable {
        var name: String
        var schemaName: String?
        var namespace: String?
    }

    struct Discriminator: Equatable {
        var name: String
        var schemaName: String?
        var namespace: String?

        var discriminatorPropertyName: String
        var mapping: [Mapping]

        struct Mapping: Equatable {
            var value: String
            var schemaName: String
        }
    }

    struct Enumeration: Equatable {
        var name: String
        var schemaName: String?
        var namespace: String?

        var mapping: [Mapping]

        struct Mapping: Equatable {
            var value: String
            var name: String
        }
    }
}
