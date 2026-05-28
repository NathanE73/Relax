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

extension Relax.Schema {
    struct Schemas {
        var discriminators: [Discriminator]
        var enumerations: [Enumeration]
        var structures: [Structure]
    }
}

extension Relax.Schema.Schemas {
    init(
        document: OpenAPIKit.OpenAPI.Document
    ) {
        discriminators = []
        enumerations = []
        structures = []

        for (schemaName, schema) in document.components.schemas {
            let schemaName = schemaName.rawValue
            if let discriminator = schema.discriminator {
                if let discriminator = Relax.Schema.Discriminator(
                    schemaName: schemaName,
                    discriminator: discriminator
                ) {
                    discriminators.append(discriminator)
                } else {
                    print("Unable to process discriminator: \(schemaName)")
                }
            } else if let allowedValues = schema.allowedValues {
                if let enumeration = Relax.Schema.Enumeration(
                    schemaName: schemaName,
                    allowedValues: allowedValues
                ) {
                    enumerations.append(enumeration)
                } else {
                    print("Unable to process enumeration: \(schemaName)")
                }
            } else if let objectContext = schema.objectContext {
                if let structure = Relax.Schema.Structure(
                    schemaName: schemaName,
                    objectContext: objectContext
                ) {
                    structures.append(structure)
                } else {
                    print("Unable to process structure: \(schemaName)")
                }
            } else {
                print("Unable to process schema: \(schemaName)")
            }
        }
    }
}
