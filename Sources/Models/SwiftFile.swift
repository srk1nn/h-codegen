//
//  SwiftFile.swift
//
//
//  Created by Sorokin Igor on 14.10.2024.
//

import Foundation
import PathKit

struct SwiftFile {

    enum DeclarationType {
        case `enum`
        case `class`
        case `protocol`
        case `extension`
    }

    struct Declaration {
        /// Type of declaration
        let type: DeclarationType
        /// Swift name, including namespaces
        /// Name of protocol, class, enum
        /// Or mark-method for extension
        let fullSwiftName: String
        /// Objc name
        /// Name of protocol, class, enum
        /// Or mark-method for extension
        let objcName: String
        /// Declaration modifier
        let accessModifier: AccessModifier
    }

    /// Path to the Swift file
    let path: Path
    /// Declaration in the file (classes, protocols, enum, extensions)
    let declarations: [Declaration]
    /// User actions
    let actions: [CodegenAction]
    /// Is file contain extensions
    let hasExtensions: Bool

    var nameWithoutExtension: String {
        path.lastComponentWithoutExtension
    }

    var overridePrefix: String? {
        actions.lazy.compactMap { $0.overridePrefix }.first
    }
}
