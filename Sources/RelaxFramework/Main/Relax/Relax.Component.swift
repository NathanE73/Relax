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

extension Relax {
    enum Component {
        case discriminator(Discriminator)
        case enumeration(Enumeration)
        case structure(Structure)
    }
}

extension Relax.Component {
    var discriminator: Relax.Discriminator? {
        guard case let .discriminator(discriminator) = self
        else { return nil }
        return discriminator
    }

    var enumeration: Relax.Enumeration? {
        guard case let .enumeration(enumeration) = self
        else { return nil }
        return enumeration
    }

    var structure: Relax.Structure? {
        guard case let .structure(structure) = self
        else { return nil }
        return structure
    }
}

extension Relax.Component {
    var namespace: String {
        switch self {
        case let .discriminator(discriminator): discriminator.namespace
        case let .enumeration(enumeration): enumeration.namespace
        case let .structure(structure): structure.namespace
        }
    }

    var name: String {
        switch self {
        case let .discriminator(discriminator): discriminator.name
        case let .enumeration(enumeration): enumeration.name
        case let .structure(structure): structure.name
        }
    }

    var fullyQualifiedName: String {
        switch self {
        case let .discriminator(discriminator): discriminator.fullyQualifiedName
        case let .enumeration(enumeration): enumeration.fullyQualifiedName
        case let .structure(structure): structure.fullyQualifiedName
        }
    }
}

extension Relax.Component {
    var allChildDiscriminators: [Relax.Discriminator] {
        switch self {
        case let .discriminator(discriminator): discriminator.allChildDiscriminators
        case .enumeration: []
        case let .structure(structure): structure.allChildDiscriminators
        }
    }

    var allChildEnumerations: [Relax.Enumeration] {
        switch self {
        case let .discriminator(discriminator): discriminator.allChildEnumerations
        case .enumeration: []
        case let .structure(structure): structure.allChildEnumerations
        }
    }

    var allChildStructures: [Relax.Structure] {
        switch self {
        case let .discriminator(discriminator): discriminator.allChildStructures
        case .enumeration: []
        case let .structure(structure): structure.allChildStructures
        }
    }
}
