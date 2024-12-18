//
//  ObjcHeaderParser.swift
//
//
//  Created by Sorokin Igor on 15.10.2024.
//

import Foundation
import PathKit
import RegexBuilder

struct ObjcHeaderParser {

    /// Parses -Swift.h file
    func parse(file: Path) throws -> ObjcHeader {
        var metadataByInterface = [String: InterfaceMetadata]()

        let lines = try file.read(.utf8).components(separatedBy: .newlines)
        var index = lines.startIndex

        while index < lines.endIndex {
            let line = lines[index]

            if !line.contains(Constants.endOfSymbol), let declarationName = line.firstMatch(regex: .interface) ?? line.firstMatch(regex: .protocol) {
                let metadata = metadata(lines: lines, declarationIndex: index)
                metadataByInterface[declarationName] = metadata
                index = metadata.end
            } else if let enumName = line.firstMatch(regex: .enum) {
                let endIndex = endIndex(lines: lines, declarationIndex: index)
                metadataByInterface[enumName] = InterfaceMetadata(start: index, end: endIndex, dependencies: [])
                index = endIndex
            } else if let funcName = line.firstMatch(regex: .markFunction) {
                /// A mark-function is detected. The extension declaration above by 1 line
                let metadata = metadata(lines: lines, declarationIndex: index - 1)
                metadataByInterface[funcName] = metadata
                index = metadata.end
            } else {
                index += 1
            }
        }

        return ObjcHeader(lines: lines, metadataByInterface: metadataByInterface)
    }

    private func metadata(lines: [String], declarationIndex: Int) -> InterfaceMetadata {
        let startIndex = declarationIndex + 1
        var dependencies: Set<Dependency> = []
        var endIndex: Int?

        for (index, line) in lines[startIndex...].enumerated() {
            line.matches(regex: .objectDependency).forEach {
                dependencies.insert(.init(
                    name: $0,
                    type: .class
                ))
            }

            line.matches(regex: .protocolDependency).forEach {
                let protocols = $0.components(separatedBy: Constants.protocolSeparator)

                protocols.forEach {
                    dependencies.insert(.init(
                        name: $0,
                        type: .protocol
                    ))
                }
            }

            line.matches(regex: .enumDependency).forEach {
                dependencies.insert(.init(
                    name: $0,
                    type: .enum
                ))
            }

            if line.contains(Constants.endOfObjectDeclaration) || line.contains(Constants.endOfEnumDeclaration) {
                endIndex = startIndex + index + 1 /// Since end not included
                break
            }
        }

        guard let endIndex else {
            preconditionFailure("End of declaration not found")
        }

        let importDependencies = inheritanceDependencies(declarationLine: lines[declarationIndex])
        dependencies.formUnion(importDependencies)

        return InterfaceMetadata(start: declarationIndex, end: endIndex, dependencies: dependencies)
    }

    private func inheritanceDependencies(declarationLine: String) -> Set<Dependency> {
        var dependencies = [String]()

        declarationLine.matches(regex: .protocolDependency).forEach {
            let protocols = $0.components(separatedBy: Constants.protocolSeparator)
            dependencies.append(contentsOf: protocols)
        }

        declarationLine.matches(regex: .inheritanceDependency).forEach {
            dependencies.append($0)
        }

        return Set(dependencies.map { Dependency(name: $0, type: .import) })
    }

    private func endIndex(lines: [String], declarationIndex: Int) -> Int {
        let startIndex = declarationIndex + 1

        for (index, line) in lines[startIndex...].enumerated() {
            if line.contains(Constants.endOfObjectDeclaration) || line.contains(Constants.endOfEnumDeclaration) {
                return startIndex + index + 1 /// Since end not included
            }
        }

        preconditionFailure("End of declaration not found")
    }

    private enum Constants {
        static let endOfSymbol: Character = ";"
        static let protocolSeparator = ", "
        static let endOfObjectDeclaration = "@end"
        static let endOfEnumDeclaration = "};"
    }
}
