//
//  ObjcHeader.swift
//  
//
//  Created by Sorokin Igor on 16.10.2024.
//

import Foundation

/// Represents contents of -Swift.h
struct ObjcHeader {
    /// -Swift.h code
    let lines: [String]
    /// Metadata grouped by Objc interface
    /// Name of protocol, class, enum
    /// Or mark-method for extension
    let metadataByInterface: [String: InterfaceMetadata]
}

struct InterfaceMetadata {
    /// Line index where declaration starts in -Swift.h
    let start: Int
    /// Line index where declaration ends in -Swift.h (not included)
    let end: Int
    /// Dependencies that interface uses
    let dependencies: Set<Dependency>
}

struct Dependency: Hashable {
    enum DependencyType {
        case `import`
        case `protocol`
        case `class`
        case `enum`
    }

    /// Name of class, enum, protocol
    let name: String
    /// Type of dependency
    let type: DependencyType
}
