//
//  ObjcCompatibleDeclarationVisitor.swift
//
//
//  Created by Sorokin Igor on 15.10.2024.
//

import Foundation
import SwiftSyntax

final class ObjcCompatibleDeclarationVisitor: SyntaxVisitor {
    private let actionParser = ActionParser()

    private(set) var declarations: [SwiftFile.Declaration] = []
    private(set) var actions: [CodegenAction] = []
    private(set) var hasExtensions: Bool = false
    private(set) var error: Error?

    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
        [token.leadingTrivia, token.trailingTrivia].forEach { trivia in
            trivia.forEach {
                switch $0 {
                case .lineComment(let comment), .blockComment(let comment), .docLineComment(let comment), .docBlockComment(let comment):
                    addActions(from: comment)
                default:
                    break
                }
            }
        }
        return continueKind()
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.shouldExportToObjc {
            declarations.append(.init(
                type: .enum,
                fullSwiftName: node.fullSwiftName,
                objcName: node.objcName ?? node.swiftName,
                accessModifier: node.accessModifier
            ))
        }
        return continueKind()
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.shouldExportToObjc {
            declarations.append(.init(
                type: .protocol,
                fullSwiftName: node.fullSwiftName,
                objcName: node.objcName ?? node.swiftName,
                accessModifier: node.accessModifier
            ))
        }
        return continueKind()
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.shouldExportToObjc {
            declarations.append(.init(
                type: .class,
                fullSwiftName: node.fullSwiftName,
                objcName: node.objcName ?? node.swiftName,
                accessModifier: node.accessModifier
            ))
        }
        return continueKind()
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        hasExtensions = true
        return continueKind()
    }

    // MARK: - Private

    private func addActions(from comment: String) {
        do {
            let actions = try actionParser.parseActions(from: comment)
            self.actions.append(contentsOf: actions)
        } catch {
            self.error = error
        }
    }

    private func continueKind() -> SyntaxVisitorContinueKind {
        error == nil ? .visitChildren : .skipChildren
    }


}
