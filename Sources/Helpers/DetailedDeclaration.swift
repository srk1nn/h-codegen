//
//  DetailedDeclaration.swift
//
//
//  Created by Sorokin Igor on 14.10.2024.
//

import Foundation
import SwiftSyntax

protocol DetailedDeclaration {
    var parent: Syntax? { get }
    var swiftName: String { get }
    var attributes: AttributeListSyntax { get }
    var modifiers: DeclModifierListSyntax { get }
}

extension DetailedDeclaration {

    var objcName: String? {
        attributes.lazy.compactMap { attribute in
            guard
                case let .attribute(syntax) = attribute,
                let argument = syntax.arguments,
                case let .objCName(objcName) = argument
            else {
                return nil
            }

            return objcName.first?.name?.text
        }.first
    }

    var accessModifier: AccessModifier {
        modifiers.lazy.compactMap { AccessModifier(rawValue: $0.name.text) }.first ?? .internal
    }

    var shouldExportToObjc: Bool {
        attributes.contains { attribute in
            guard 
                case let .attribute(syntax) = attribute,
                let attributeName = syntax.attributeName.as(IdentifierTypeSyntax.self)?.name.text
            else {
                return false
            }

            return attributeName == Constants.objcMembers || attributeName == Constants.objc
        }
    }

    var namespace: String {
        parent?.namespace ?? ""
    }

    var fullSwiftName: String {
        namespace.isEmpty ? swiftName : namespace + ".\(swiftName)"
    }
}

private extension Syntax {
    var namespace: String {
        if let node = parent?.as(ExtensionDeclSyntax.self) {
            let parentNamespace = node.namespace
            return parentNamespace.isEmpty ? node.swiftName : parentNamespace + ".\(node.swiftName)"
        } else if let node = parent?.as(ClassDeclSyntax.self) {
            let parentNamespace = node.namespace
            return parentNamespace.isEmpty ? node.swiftName : parentNamespace + ".\(node.swiftName)"
        } else if let node = parent?.as(StructDeclSyntax.self) {
            let parentNamespace = node.namespace
            return parentNamespace.isEmpty ? node.swiftName : parentNamespace + ".\(node.swiftName)"
        } else if let node = parent?.as(EnumDeclSyntax.self) {
            let parentNamespace = node.namespace
            return parentNamespace.isEmpty ? node.swiftName : parentNamespace + ".\(node.swiftName)"
        } else if let parent {
            return parent.namespace
        }
        return ""
    }
}

private enum Constants {
    static let objcMembers = "objcMembers"
    static let objc = "objc"
}
