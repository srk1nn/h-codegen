//
//  ExtensionsRewriter.swift
//  
//
//  Created by Sorokin Igor on 14.10.2024.
//

import Foundation
import SwiftSyntax

final class ExtensionsRewriter: SyntaxRewriter {
    private(set) var extensions: [SwiftFile.Declaration] = []

    private let internalObjcClasses: [String]

    init(internalObjcClasses: [String]) {
        self.internalObjcClasses = internalObjcClasses
    }

    override func visit(_ node: ExtensionDeclSyntax) -> DeclSyntax {
        let shouldExportToObjc: () -> Bool = {
            node.memberBlock.members.contains(where: {
                if let decl = $0.decl.as(FunctionDeclSyntax.self) {
                    return decl.shouldExportToObjc
                } else if let decl = $0.decl.as(VariableDeclSyntax.self) {
                    return decl.shouldExportToObjc
                } else if let decl = $0.decl.as(InitializerDeclSyntax.self) {
                    return decl.shouldExportToObjc
                } else if let decl = $0.decl.as(SubscriptDeclSyntax.self) {
                    return decl.shouldExportToObjc
                }
                return false
            })
        }

        guard node.shouldExportToObjc || internalObjcClasses.contains(node.fullSwiftName) || shouldExportToObjc() else {
            return DeclSyntax(node)
        }

        var node = node
        var blockMembers = node.memberBlock.members
        let funcName = generateMarkFunctionName()
        let markFunction = markFunction(with: funcName)
        let markFunctionBlock = MemberBlockItemSyntax(decl: markFunction)

        /// A mark-function is always added after the extension declaration to simplify search in the ``ObjcHeaderParser``
        blockMembers.insert(markFunctionBlock, at: blockMembers.startIndex)
        node.memberBlock.members = blockMembers

        extensions.append(.init(
            type: .extension,
            fullSwiftName: funcName,
            objcName: funcName,
            accessModifier: node.accessModifier
        ))

        return DeclSyntax(node)
    }

    // MARK: - Private

    private func markFunction(with name: String) -> FunctionDeclSyntax {
        let objcId = IdentifierTypeSyntax(name: .identifier("objc"))
        let objc = AttributeSyntax(atSign: .atSignToken(), attributeName: objcId, trailingTrivia: .space)
        let keyword = TokenSyntax.keyword(.func, trailingTrivia: .space)
        let name = TokenSyntax.identifier(name)
        let parameters = FunctionParameterClauseSyntax(parameters: [])
        let signature = FunctionSignatureSyntax(parameterClause: parameters, trailingTrivia: .space)
        let body = CodeBlockSyntax(statements: [])

        return FunctionDeclSyntax(
            leadingTrivia: .newline,
            attributes: .init([.attribute(objc)]),
            funcKeyword: keyword,
            name: name,
            signature: signature,
            body: body,
            trailingTrivia: .newline
        )
    }

    private func generateMarkFunctionName() -> String {
        Constants.randomizer += 1
        return "\(Constants.markFunctionName)\(Constants.randomizer)"
    }

    private enum Constants {
        static let markFunctionName = "hcodegenFunctionForExtension"
        static var randomizer = 0
    }
}
