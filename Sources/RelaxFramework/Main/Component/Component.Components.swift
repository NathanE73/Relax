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
    struct Components {
        var discriminators: [Discriminator]
        var enumerations: [Enumeration]
        var structures: [Structure]
    }
}

extension Component.Components {
    init(
        configurations: Configuration.Configurations,
        document: OpenAPIKit.OpenAPI.Document
    ) {
        enumerations = configurations.enumerations.compactMap { configuration in
            configuration.componentEnumeration(document: document)
        }

        // TODO: remove
        globalEnumerations = enumerations
        // print("Number of enumerations: \(enumerations.count)")
        // print("  - \(enumerations.map(\.name).sorted().joined(separator: "\n  - "))")

        discriminators = configurations.discriminators.compactMap { configuration in
            configuration.componentDiscriminator(document: document)
        }

        // TODO: remove
        globalDiscriminators = discriminators
        // print("Number of enumerations: \(discriminators.count)")
        // print("  - \(discriminators.map(\.name).sorted().joined(separator: "\n  - "))")

        structures = configurations.structures.compactMap { configuration in
            configuration.componentStructure(document: document)
        }
        structures.append(contentsOf: missingGlobalStructures(document, structures))

        // TODO: remove
        globalStructures = structures
    }
}

// TODO: remove
var globalDiscriminators: [Component.Discriminator] = []
var globalEnumerations: [Component.Enumeration] = []
var globalStructures: [Component.Structure] = []

private func missingGlobalStructures(
    _ document: OpenAPIKit.OpenAPI.Document,
    _ structures: [Component.Structure]
) -> [Component.Structure] {
    // TODO: how can we simplify this and also support enumerations, and discriminators?
    var missingStructureConfigurations: [Configuration.Structure] = []

    for (schemaName, schema) in document.components.schemas {
        guard schema.objectContext != nil else {
            continue
        }

        let schemaName = schemaName.rawValue

        if structures.firstWith(namespace: nil, schemaName: schemaName) == nil {
            missingStructureConfigurations.append(
                Configuration.Structure(
                    existing: false,
                    schemaName: schemaName,
                    name: schemaName,
                    properties: []
                )
            )
        }
    }

    return missingStructureConfigurations.compactMap { configuration in
        configuration.componentStructure(document: document)
    }
}
