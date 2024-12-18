//
//  DeclSyntax+DetailedDeclaration.swift
//
//
//  Created by Sorokin Igor on 15.10.2024.
//

import Foundation
import SwiftSyntax

extension EnumDeclSyntax: DetailedDeclaration {
    var swiftName: String {
        name.text
    }
}

extension ClassDeclSyntax: DetailedDeclaration {
    var swiftName: String {
        name.text
    }
}

extension ExtensionDeclSyntax: DetailedDeclaration {
    var swiftName: String {
        extendedType.description.trimmingCharacters(in: .whitespaces)
    }
}

extension StructDeclSyntax: DetailedDeclaration {
    var swiftName: String {
        name.text
    }
}

extension ProtocolDeclSyntax: DetailedDeclaration {
    var swiftName: String {
        name.text
    }
}

extension FunctionDeclSyntax: DetailedDeclaration {
    var swiftName: String {
        name.text
    }
}

extension VariableDeclSyntax: DetailedDeclaration {
    var swiftName: String {
        description
    }
}

extension InitializerDeclSyntax: DetailedDeclaration {
    var swiftName: String {
        description
    }
}

extension SubscriptDeclSyntax: DetailedDeclaration {
    var swiftName: String {
        description
    }
}
