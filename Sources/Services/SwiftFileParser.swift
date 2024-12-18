//
//  SwiftFileParser.swift
//
//
//  Created by Sorokin Igor on 14.10.2024.
//

import Foundation
import SwiftParser
import SwiftSyntax
import PathKit
import SwiftCLI

/// Parser for Swift files
///
/// The parser should find all declarations that will be exported to an Objective-C.
/// While working with object's declarations are straightforward, extensions can be more complex.
/// An extension can be exported to an Objective-C even wihtout @objc attribute
/// (for example, an extension for @objcMembers or extension conformance to @objc protocol).
/// So it is difficult to determine whether the extension will be exported to an Objective-C.
/// To handle this, the parser works in two passes.
///
/// It collects all enums, classes, and protocols declarations.
/// Finally, for each extension of a class (that should be exported to an Objective-C) the parser adds a mark-function.
/// This function will later help us to determine which extension should be exported and which file the extension belongs to.
struct SwiftFileParser {

    func parse(from directory: Path) throws -> [SwiftFile] {
        let paths = try directory.recursiveChildren().filter { $0.extension == "swift" }

        let swiftFiles = try paths.enumerated().map { (index, path) in
                Logger.progress("Searching Swift declarations", progress: Float(index) / Float(paths.count - 1))

                let source = try path.read(.utf8)
                let syntax = Parser.parse(source: source)
                let visitor = ObjcCompatibleDeclarationVisitor(viewMode: .fixedUp)
                visitor.walk(syntax)

                if let error = visitor.error {
                    throw error
                }

                return SwiftFile(
                    path: path,
                    declarations: visitor.declarations,
                    actions: visitor.actions,
                    hasExtensions: visitor.hasExtensions
                )
            }

        let internalObjcClasses = swiftFiles.flatMap { swiftFile in
            swiftFile.declarations.filter { $0.type == .class }.map { $0.fullSwiftName }
        }

        let rewrittenSwiftFiles = try swiftFiles.enumerated().map { (index, swiftFile) in
            Logger.progress("Rewritting Swift extensions", progress: Float(index) / Float(swiftFiles.count - 1))

            guard swiftFile.hasExtensions else {
                return swiftFile
            }

            let source = try swiftFile.path.read(.utf8)
            let syntax = Parser.parse(source: source)
            let visitor = ExtensionsRewriter(internalObjcClasses: internalObjcClasses)
            let newSyntax = visitor.rewrite(syntax)

            if newSyntax != syntax._syntaxNode {
                try swiftFile.path.write(newSyntax.description, encoding: .utf8)
            }

            return SwiftFile(
                path: swiftFile.path,
                declarations: swiftFile.declarations + visitor.extensions,
                actions: swiftFile.actions,
                hasExtensions: swiftFile.hasExtensions
            )
        }

        return rewrittenSwiftFiles
    }

}
