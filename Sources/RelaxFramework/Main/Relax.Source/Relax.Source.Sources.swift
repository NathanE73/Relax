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

extension Relax.Source {
    struct Sources {
        var enumerations: [Enumeration]
        var discriminators: [Discriminator]
        var structures: [Structure]
    }
}

extension Relax.Source.Sources {
    init(
        configurations: Relax.Configuration.Configurations,
        schemas: Relax.Schema.Schemas,
        platform: Platform
    ) {
        enumerations = configurations.enumerations.compactMap { configuration in
            if let schema = schemas.enumerations.firstWith(schemaName: configuration.schemaName) {
                Relax.Source.Enumeration(
                    configuration: configuration,
                    schema: schema,
                    naming: platform.naming
                )
            } else if let schema = schemas.structures.firstWith(schemaName: configuration.schemaName) {
                Relax.Source.Enumeration(
                    configuration: configuration,
                    schema: schema,
                    naming: platform.naming
                )
            } else {
                nil
            }
        }

        discriminators = configurations.discriminators.compactMap { configuration in
            if let schema = schemas.discriminators.firstWith(schemaName: configuration.schemaName) {
                Relax.Source.Discriminator(
                    configuration: configuration,
                    schema: schema,
                    naming: platform.naming
                )
            } else if let schema = schemas.structures.firstWith(schemaName: configuration.schemaName) {
                Relax.Source.Discriminator(
                    configuration: configuration,
                    schema: schema,
                    naming: platform.naming
                )
            } else {
                nil
            }
        }

        structures = configurations.structures.compactMap { configuration in
            if let schema = schemas.structures.firstWith(schemaName: configuration.schemaName) {
                Relax.Source.Structure(
                    configuration: configuration,
                    schema: schema,
                    clarifyPropertyType: configurations.clarifyPropertyType
                )
            } else {
                nil
            }
        }

        let enumerationSchemaNames = enumerations.compactMap(\.schemaName)
        enumerations.append(contentsOf: schemas.enumerations.compactMap { schema in
            if !enumerationSchemaNames.contains(schema.schemaName) {
                Relax.Source.Enumeration(
                    configuration: nil,
                    schema: schema,
                    naming: platform.naming
                )
            } else {
                nil
            }
        })

        let discriminatorSchemaNames = discriminators.compactMap(\.schemaName)
        discriminators.append(contentsOf: schemas.discriminators.compactMap { schema in
            if !discriminatorSchemaNames.contains(schema.schemaName) {
                Relax.Source.Discriminator(
                    configuration: nil,
                    schema: schema,
                    naming: platform.naming
                )
            } else {
                nil
            }
        })

        let structureSchemaNames = structures.compactMap(\.schemaName)
        structures.append(contentsOf: schemas.structures.compactMap { schema in
            if !structureSchemaNames.contains(schema.schemaName) {
                Relax.Source.Structure(
                    configuration: nil,
                    schema: schema,
                    clarifyPropertyType: configurations.clarifyPropertyType
                )
            } else {
                nil
            }
        })
    }
}
