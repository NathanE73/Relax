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

extension Relax.Configuration {
    struct Configurations {
        var discriminators: [Discriminator]
        var enumerations: [Enumeration]
        var structures: [Structure]

        var discriminatorModifications: [Discriminator]
        var enumerationModifications: [Enumeration]
        var structureModifications: [Structure]

        var kotlinMoshi: KotlinMoshi?
    }
}

extension Relax.Configuration.Configurations {
    init(
        configuration: RelaxConfiguration,
        platform: RelaxCommand.Platform
    ) {
        func addNamePrefix(_ name: String) -> String {
            if let namePrefix = configuration.naming?.prefix {
                namePrefix + name
            } else {
                name
            }
        }

        discriminators = configuration.namespaces.flatMap { namespace in
            namespace.discriminators?.compactMap { discriminator in
                Relax.Configuration.Discriminator(
                    namespace: namespace,
                    discriminator: discriminator,
                    addNamePrefix: addNamePrefix
                )
            } ?? []
        }

        discriminatorModifications = configuration.modifications?.discriminators?.compactMap { discriminator in
            Relax.Configuration.Discriminator(
                namespace: nil,
                discriminator: discriminator,
                addNamePrefix: addNamePrefix
            )
        } ?? []

        enumerations = configuration.namespaces.flatMap { namespace in
            namespace.enumerations?.compactMap { enumeration in
                Relax.Configuration.Enumeration(
                    namespace: namespace,
                    enumeration: enumeration,
                    addNamePrefix: addNamePrefix
                )
            } ?? []
        }

        enumerationModifications = configuration.modifications?.enumerations?.compactMap { enumeration in
            Relax.Configuration.Enumeration(
                namespace: nil,
                enumeration: enumeration,
                addNamePrefix: addNamePrefix
            )
        } ?? []

        structures = configuration.namespaces.flatMap { namespace in
            namespace.structures?.compactMap { structure in
                Relax.Configuration.Structure(
                    namespace: namespace,
                    structure: structure,
                    addNamePrefix: addNamePrefix
                )
            } ?? []
        }

        structureModifications = configuration.modifications?.structures?.compactMap { structure in
            Relax.Configuration.Structure(
                namespace: nil,
                structure: structure,
                addNamePrefix: addNamePrefix
            )
        } ?? []

        if platform == .kotlinMoshi {
            kotlinMoshi = Relax.Configuration.KotlinMoshi(
                kotlinMoshi: configuration.kotlinMoshi,
                addNamePrefix: addNamePrefix
            )
        }
    }
}
