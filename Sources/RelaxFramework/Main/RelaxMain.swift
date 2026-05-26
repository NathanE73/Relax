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

// TODO: report on what schemas were not used?
// TODO: generate root swift namespace

// TODO: review
public struct RelaxMain {
    var configurationFile: String

    var input: [String]

    var output: String

    var oneTime: Bool

    var documents: [OpenAPIKit.OpenAPI.Document]

    var platform: Platform

    var kotlinMoshiConfiguration: Configuration.KotlinMoshi?

    var discriminatorConfigurations: [Configuration.Discriminator] = []
    var enumerationConfigurations: [Configuration.Enumeration] = []
    var structureConfigurations: [Configuration.Structure] = []

    init(_ command: RelaxCommand, _ configuration: RelaxConfiguration?) throws {
        configurationFile = configuration?.file ?? ""

        if let input = configuration?.input, !input.isEmpty {
            self.input = input
        } else {
            throw RelaxError.missingInput
        }

        if let output = configuration?.output {
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

        switch command.platform {
        case .kotlin: platform = .kotlin(.kotlinx)
        case .kotlinMoshi: platform = .kotlin(.moshi)
        case .swift: platform = .swift
        }

        if let configuration {
            if command.platform == .kotlinMoshi {
                kotlinMoshiConfiguration = configuration.kotlinMoshiConfiguration()
            }

            discriminatorConfigurations = configuration.discriminatorConfigurations()
            enumerationConfigurations = configuration.enumerationConfigurations()
            structureConfigurations = configuration.structureConfigurations()
        }
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

            let main = try RelaxMain(command, configuration)
            try main.run()
        } catch {
            print(error)
            exit(64)
        }
    }

    func run() throws {
        let document = documents.first!

        globalEnumerations = enumerationConfigurations.compactMap { configuration in
            configuration.componentEnumeration(document: document)
        }

        globalDiscriminators = discriminatorConfigurations.compactMap { configuration in
            configuration.componentDiscriminator(document: document)
        }

        globalStructures = structureConfigurations.compactMap { configuration in
            configuration.componentStructure(document: document)
        }
        globalStructures.append(contentsOf: missingGlobalStructures())

        generateSourceCode()
    }

    func generateSourceCode() {
        let relaxComponents = (
            globalDiscriminators.filter { !$0.existing }.compactMap { $0.relaxComponent() } +
                globalEnumerations.filter { !$0.existing }.compactMap { $0.relaxComponent() } +
                globalStructures.filter { !$0.existing }.compactMap { $0.relaxComponent() }
        ).sorted(by: \.fullyQualifiedName)

        for relaxComponent in relaxComponents {
            generateRelaxComponentSourceCode(relaxComponent)
        }

        if let adapters = kotlinMoshiConfiguration?.adapters {
            generateMoshiAdaptersSourceCode(adapters)
        }
    }

    func generateRelaxComponentSourceCode(_ relaxComponent: Relax.Component) {
        let path = sourceCodePath(namespace: relaxComponent.namespace)
        let filename = sourceCodeFilename(namespace: relaxComponent.namespace, componentName: relaxComponent.name)

        switch platform {
        case let .kotlin(framework):
            let source = KotlinSource()
            source.appendComponent(relaxComponent, framework, filename: filename, includeGeneratedComment: !oneTime)
            let sourceFile = SourceFile(filename, at: path)
            sourceFile.write(source.source)
        case .swift:
            let source = SwiftSource()
            source.appendComponent(relaxComponent, filename: filename, includeGeneratedComment: !oneTime)
            let sourceFile = SourceFile(filename, at: path)
            sourceFile.write(source.source)
        }
    }

    func generateMoshiAdaptersSourceCode(_ adapters: Configuration.KotlinMoshi.Adapters) {
        for mapping in adapters.mapping {
            let path = sourceCodePath(namespace: adapters.namespace)
            let filename = sourceCodeFilename(namespace: adapters.namespace, componentName: mapping.name)

            let relaxComponents: [Relax.Component] = (
                globalDiscriminators.compactMap { $0.relaxComponent() } +
                    globalStructures.compactMap { $0.relaxComponent() }
            )
            .filter { $0.namespace == mapping.namespace }
            .filter { $0.discriminator != nil || $0.structure?.discriminators.isEmpty == false }
            .sorted(by: \.fullyQualifiedName)

            let source = KotlinSource()
            source.appendMoshiDiscriminatorAdapter(
                relaxComponents: relaxComponents,
                mappingName: mapping.name,
                namespace: adapters.namespace,
                filename: filename,
                includeGeneratedComment: !oneTime
            )

            let sourceFile = SourceFile(filename, at: path)
            sourceFile.write(source.source)
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

// TODO: refactor

var globalDiscriminators: [Component.Discriminator] = []
var globalEnumerations: [Component.Enumeration] = []
/// used twice in ComponentDiscriminator+Relax
var globalStructures: [Component.Structure] = []

extension RelaxMain {
    func missingGlobalStructures() -> [Component.Structure] {
        let document = documents.first!

        // TODO: how can we simplify this and also support enumerations, and discriminators?
        var missingStructureConfigurations: [Configuration.Structure] = []

        for (schemaName, schema) in document.components.schemas {
            guard schema.objectContext != nil else {
                continue
            }

            let schemaName = schemaName.rawValue

            if globalStructures.firstWith(namespace: nil, schemaName: schemaName) == nil {
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
}
