//
//  ObjcHeadersMapper.swift
//  
//
//  Created by Sorokin Igor on 25.10.2024.
//

import Foundation
import PathKit

struct ObjcHeadersMapper {

    /// Splits Objective-C declarations into separate headers according to Swift files.
    func map(swiftFiles: [SwiftFile], from objcHeader: ObjcHeader, sdk: String, prefix: String) throws -> [HeaderDescription] {
        var headers = [HeaderDescription]()
        let importsByDeclarations = importsByDeclarations(sdk: sdk, swiftFiles: swiftFiles, prefix: prefix)
        let metadataByInterface = objcHeader.metadataByInterface
        var lines = objcHeader.lines

        for swiftFile in swiftFiles {
            var content = [String]()
            var dependencies: Set<Dependency> = []

            for declaration in swiftFile.declarations where declaration.accessModifier == .internal {
                guard let metadata = metadataByInterface[declaration.objcName] else {
                    preconditionFailure("Could not find Objective-C metadata for interface \(declaration.objcName)")
                }

                if isEmptyExtension(declaration, metadata: metadata) {
                    continue
                }

                fixEnumName(declaration, metadata: metadata, in: &lines)

                var code = Array(lines[metadata.start..<metadata.end])

                /// remove mark-functions
                code = code.filter { !$0.contains(Constants.markFunctionName) }

                content.append(code.joined(separator: "\n"))
                dependencies.formUnion(metadata.dependencies)
            }

            if content.isEmpty {
                continue
            }

            let forwardDeclarations = forwardDeclarations(dependencies: dependencies)

            let imports = Constants.predefinedImports + imports(
                for: swiftFile.nameWithoutExtension,
                dependencies: dependencies,
                actions: swiftFile.actions,
                importsByDeclarations: importsByDeclarations
            )

            if !forwardDeclarations.isEmpty {
                content.insert(forwardDeclarations.joined(separator: "\n"), at: 0)
            }

            if !imports.isEmpty {
                content.insert(imports.joined(separator: "\n"), at: 0)
            }

            content.insert(Constants.fileHeader, at: 0)

            let name = objcFileName(swiftFile, prefix: prefix)
            let source = content.joined(separator: "\n\n")

            let header = HeaderDescription(name: name, content: source)
            headers.append(header)
        }

        return headers
    }

    /// Creates file imports for every Swift declaration
    ///
    /// This dictionary uses for quick access to file import by Objective-C name.
    /// The key is Objective-C object name, the value is corresponding file import for this object.
    private func importsByDeclarations(sdk: String, swiftFiles: [SwiftFile], prefix: String) -> [String: String] {
        var importsByDecl = [String: String]()

        swiftFiles.forEach { swiftFile in
            swiftFile.declarations.forEach { declaration in
                if declaration.accessModifier == .public {
                    importsByDecl[declaration.objcName] = "#import <\(sdk)/\(sdk)-Swift.h>"
                } else {
                    importsByDecl[declaration.objcName] = "#import \"\(objcFileName(swiftFile, prefix: prefix))\""
                }
            }
        }

        return importsByDecl
    }

    private func isEmptyExtension(_ declaration: SwiftFile.Declaration, metadata: InterfaceMetadata) -> Bool {
        /// empty extension always contains 3 line in metadata, as follows
        /// 1. extension declaration 2. mark-function 3. end
        declaration.type == .extension && metadata.end - metadata.start == 3
    }

    /// SWIFT ENUM also contains Swift name of enum.
    /// We don't want to show this name, so replacing it with objcName.
    private func fixEnumName(_ declaration: SwiftFile.Declaration, metadata: InterfaceMetadata, in lines: inout [String]) {
        guard let swiftName = declaration.fullSwiftName.components(separatedBy: ".").last else {
            preconditionFailure("Enum name must be non empty")
        }
        lines[metadata.start] = lines[metadata.start].replacingOccurrences(
            of: "\\b\(swiftName)",
            with: declaration.objcName,
            options: .regularExpression
        )
    }

    private func imports(for file: String, dependencies: Set<Dependency>, actions: [CodegenAction], importsByDeclarations: [String: String]) -> [String] {
        var imports: Set<String> = []

        dependencies
            .filter { $0.type == .import }
            .forEach {
                if let name = importsByDeclarations[$0.name] {
                    imports.insert(name)
                }
            }

        /// remove self imports
        imports = imports.filter { !$0.contains(file) }

        actions.forEach {
            switch $0 {
            case .header(let header):
                imports.insert("#import \"\(header)\"")
            case .framework(let framework):
                imports.insert("#import <\(framework)/\(framework).h>")
            default:
                break
            }
        }

        return Array(imports).sorted()
    }

    private func forwardDeclarations(dependencies: Set<Dependency>) -> [String] {
        dependencies.filter { $0.type != .import }.compactMap {
            switch $0.type {
            case .class:
                "@class \($0.name);"
            case .enum:
                "enum \($0.name) : NSInteger;"
            case .protocol:
                "@protocol \($0.name);"
            default:
                nil
            }
        }.sorted()
    }

    private func objcFileName(_ file: SwiftFile, prefix: String) -> String {
        "\(file.overridePrefix ?? prefix)\(file.nameWithoutExtension).h"
    }

    private enum Constants {
        static let markFunctionName = "hcodegenFunctionForExtension"
        static let fileHeader = "// This file was automatically generated and should not be edited."
        static let predefinedImports = ["#import <Foundation/Foundation.h>", "#import \"InteroperabilityMacro.h\""]
    }
}
