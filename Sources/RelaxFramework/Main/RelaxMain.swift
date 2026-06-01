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
import Yams

public struct RelaxMain {
    var configurationFile: String

    var input: [String]

    var output: String

    var oneTime: Bool

    var documents: [OpenAPIKit.OpenAPI.Document]

    var platform: Platform

    var sources: Relax.Source.Sources

    init(_ command: RelaxCommand, _ configuration: RelaxConfiguration) throws {
        configurationFile = configuration.file ?? ""

        if let input = configuration.input, !input.isEmpty {
            self.input = input
        } else {
            throw RelaxError.missingInput
        }

        if let output = configuration.output {
            self.output = output
        } else {
            throw RelaxError.missingOutput
        }

        oneTime = command.oneTime

        let decoder = YAMLDecoder()
        do {
            documents = try input.map { input in
                let url = URL(fileURLWithPath: input)
                let data = try Data(contentsOf: url)
                return try decoder.decode(OpenAPI.Document.self, from: data)
            }
        } catch {
            print("Unable to load document: \(error)")
            throw error
        }

        platform = switch command.platform {
        case .kotlin: .kotlin(.kotlinx)
        case .kotlinMoshi: .kotlin(.moshi)
        case .swift: .swift
        }

        let configurations = Relax.Configuration.Configurations(
            configuration: configuration,
            platform: command.platform
        )

        let schemas = Relax.Schema.Schemas(document: documents.first!)

        sources = Relax.Source.Sources(
            configurations: configurations,
            schemas: schemas
        )
    }

    public static func main() {
        do {
            let command = RelaxCommand.parseOrExit()

            let configuration: RelaxConfiguration? = if let config = command.config {
                try RelaxConfiguration(file: config)
            } else {
                try RelaxConfiguration(
                    path: FileManager.default.currentDirectoryPath,
                    filenames: command.platform.configurationFilenames
                )
            }

            guard let configuration else {
                throw RelaxError.missingConfiguration
            }

            if let file = configuration.file {
                print("Processing configuration: \(file)")
            }

            let main = try RelaxMain(command, configuration)
            try main.run()
        } catch {
            print(error)
            exit(64)
        }
    }

    func run() throws {
        generateSourceCode(from: sources)
    }

    func generateSourceCode(from sources: Relax.Source.Sources) {
        for discriminator in sources.discriminators {
            guard let namespace = discriminator.namespace else { continue }
            let path = sourceCodePath(namespace: namespace)
            let filename = sourceCodeFilename(namespace: namespace, componentName: discriminator.name)

            switch platform {
            case let .kotlin(framework):
                let source = KotlinSource()
                source.appendDiscriminator(discriminator, framework, filename: filename, includeGeneratedComment: !oneTime)
                let sourceFile = SourceFile(filename, at: path)
                sourceFile.write(source.source)
            case .swift:
                let source = SwiftSource()
                source.appendDiscriminator(discriminator, filename: filename, includeGeneratedComment: !oneTime)
                let sourceFile = SourceFile(filename, at: path)
                sourceFile.write(source.source)
            }
        }

        for enumeration in sources.enumerations {
            guard let namespace = enumeration.namespace else { continue }
            let path = sourceCodePath(namespace: namespace)
            let filename = sourceCodeFilename(namespace: namespace, componentName: enumeration.name)

            switch platform {
            case let .kotlin(framework):
                let source = KotlinSource()
                source.appendEnumeration(enumeration, framework, filename: filename, includeGeneratedComment: !oneTime)
                let sourceFile = SourceFile(filename, at: path)
                sourceFile.write(source.source)
            case .swift:
                let source = SwiftSource()
                source.appendEnumeration(enumeration, filename: filename, includeGeneratedComment: !oneTime)
                let sourceFile = SourceFile(filename, at: path)
                sourceFile.write(source.source)
            }
        }

        for structure in sources.structures {
            guard let namespace = structure.namespace else { continue }
            let path = sourceCodePath(namespace: namespace)
            let filename = sourceCodeFilename(namespace: namespace, componentName: structure.name)

            switch platform {
            case let .kotlin(framework):
                let source = KotlinSource()
                source.appendStructure(structure, sources, framework, filename: filename, includeGeneratedComment: !oneTime)
                let sourceFile = SourceFile(filename, at: path)
                sourceFile.write(source.source)
            case .swift:
                let source = SwiftSource()
                source.appendStructure(structure, sources, filename: filename, includeGeneratedComment: !oneTime)
                let sourceFile = SourceFile(filename, at: path)
                sourceFile.write(source.source)
            }
        }
    }

    func sourceCodePath(namespace: String) -> String {
        let namespacePath = namespace.replacingOccurrences(of: ".", with: "/")
        return "\(output)/\(namespacePath)/"
    }

    func sourceCodeFilename(namespace: String, componentName: String) -> String {
        switch platform {
        case .kotlin:
            let fileExtension = oneTime ? Filename.kotlinExtension : Filename.kotlinRelaxExtension
            return "\(componentName)\(fileExtension)"
        case .swift:
            let fileExtension = oneTime ? Filename.swiftExtension : Filename.swiftRelaxExtension
            return "\(namespace).\(componentName)\(fileExtension)"
        }
    }
}
