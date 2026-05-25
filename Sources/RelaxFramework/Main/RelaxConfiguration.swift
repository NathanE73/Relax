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
import Yams

struct RelaxConfiguration: Decodable {
    var file: String?

    var input: [String]?

    var output: String?

    var naming: Naming?

    struct Naming: Decodable {
        var prefix: String?
        // TODO: enumerationNaming: upper snake-case, camel-case, capital-snake-case
    }

    var kotlinMoshi: KotlinMoshi?

    struct KotlinMoshi: Decodable {
        var adapters: Adapters?

        struct Adapters: Decodable {
            var namespace: String
            var mapping: [Mapping]

            struct Mapping: Decodable {
                var name: String
                var namespace: String
            }
        }
    }

    var namespaces: [Namespace]

    struct Namespace: Decodable {
        var namespace: String
        var codable: CodableProtocol?
        var enumerations: [Enumeration]?
        var structures: [Structure]?
        var discriminators: [Discriminator]?
    }

    var modifications: Modification?

    struct Modification: Decodable {
        var enumerations: [Enumeration]?
        var structures: [Structure]?
    }

    struct Enumeration: Decodable {
        var existing: Bool?

        var schema: String
        var name: String?
        var propertyName: String?
        var values: [Value]?

        struct Value: Decodable {
            var value: String
            var name: String?
        }
    }

    struct Structure: Decodable {
        var existing: Bool?

        var schema: String
        var name: String?
        var identifiablePropertyName: String?
        var properties: [Property]?

        struct Property: Decodable {
            var name: String
            var type: String?
            var discard: Bool?
            var values: [Value]?

            struct Value: Decodable {
                var value: String
                var name: String?
            }
        }
    }

    struct Discriminator: Decodable {
        var existing: Bool?

        var name: String
        var property: Property
        var mapping: [Mapping]

        struct Property: Decodable {
            var name: String
            var type: String?
        }

        struct Mapping: Decodable {
            var value: String
            var schema: String
            var name: String?
        }
    }
}

extension RelaxConfiguration {
    init?(path startingPath: String, filenames: [String]) throws {
        let fileManager = FileManager.default

        var currentPath = startingPath
        while fileManager.isDirectory(currentPath) {
            for filename in filenames {
                let configurationFile = currentPath.appendingPathComponent(filename)
                if fileManager.isFile(configurationFile) {
                    self = try RelaxConfiguration(file: configurationFile)
                    return
                }
            }

            let parentPath = currentPath.deletingLastPathComponent
            if parentPath == currentPath {
                break
            }
            currentPath = parentPath
        }

        return nil
    }

    init(file: String) throws {
        do {
            let url = URL(fileURLWithPath: file)
            let data = try Data(contentsOf: url)

            self = try YAMLDecoder().decode(Self.self, from: data)
            self.file = file
        } catch {
            #if DEBUG
                print("Unable to read configuration: \(error)")
            #endif
            throw RelaxError.invalidConfiguration(file: file)
        }
    }
}

extension RelaxConfiguration {
    func addNamePrefix(_ name: String) -> String {
        if let namePrefix = naming?.prefix {
            namePrefix + name
        } else {
            name
        }
    }
}
